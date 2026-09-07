#!/bin/bash
# Generates ~/.dbt/profiles.yml for the course, in your HOME directory, so that
# dbt, dbt init and the VS Code extensions all pick it up.
# A link at ./profiles.yml makes the same file visible in the repository.
#
# Every profile it writes gets a target for each backend you configured:
#   postgres    - the local database in the codespace (always written)
#   databricks  - your Databricks Free Edition workspace (needs .env)
#   snowflake   - a Snowflake account (needs .env)
#
# It also writes an [academy] profile to ~/.databrickscfg, so the Databricks
# VS Code extension connects to the same workspace. Other profiles in that
# file are kept.
#
# It writes a dbt profile for:
#   - every dbt project it finds in this repository (read from dbt_project.yml)
#   - any extra name you pass as an argument
#   - the fallback names dbt_academy and covid
#
# Re-run it any time. It is safe to run twice, and it repairs the file after
# `dbt init` has overwritten it.
#
# Usage:
#   ./create_profiles.sh                       # Databricks if configured, else Postgres
#   ./create_profiles.sh --target databricks   # databricks is the default target
#   ./create_profiles.sh --target snowflake    # snowflake is the default target
#   ./create_profiles.sh my_project            # also write a profile 'my_project'
#
# Then:
#   dbt debug                        # tests the default target
#   dbt debug --target databricks    # tests one specific target
#   dbt run --target databricks      # runs the project on that backend
set -euo pipefail
umask 077

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILES_PATH="${DBT_PROFILES_DIR:-${HOME}/.dbt}/profiles.yml"
VISIBLE_PROFILE="${SCRIPT_DIR}/profiles.yml"
DATABRICKS_CFG="${DATABRICKS_CONFIG_FILE:-${HOME}/.databrickscfg}"
DEFAULT_TARGET=""
EXTRA_NAMES=()

usage() {
  sed -n '2,32p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -t|--target)
      DEFAULT_TARGET="${2:-}"
      case "${DEFAULT_TARGET}" in
        postgres|databricks|snowflake) ;;
        *) echo "Error: --target must be postgres, databricks or snowflake." >&2; exit 1 ;;
      esac
      shift 2
      ;;
    -h|--help) usage ;;
    -*) echo "Error: unknown option '$1'. Use --help." >&2; exit 1 ;;
    *) EXTRA_NAMES+=("$1"); shift ;;
  esac
done

# ---------------------------------------------------------------------------
# Load settings from .env (all optional except the credentials themselves)
# ---------------------------------------------------------------------------
DATABRICKS_HOST=""; DATABRICKS_HTTP_PATH=""; DATABRICKS_TOKEN=""
DATABRICKS_CATALOG="workspace"; DATABRICKS_SCHEMA="dbt"

SNOWFLAKE_ACCOUNT=""; SNOWFLAKE_USER=""
SNOWFLAKE_PRIVATE_KEY_PATH=""; SNOWFLAKE_PRIVATE_KEY_PASSPHRASE=""
SNOWFLAKE_PASSWORD=""
SNOWFLAKE_ROLE=""; SNOWFLAKE_WAREHOUSE="COMPUTE_WH"
SNOWFLAKE_DATABASE=""; SNOWFLAKE_SCHEMA="dbt"

POSTGRES_HOST="db"; POSTGRES_PORT="5432"
POSTGRES_USER="postgres"; POSTGRES_PASSWORD="postgres"
POSTGRES_DBNAME="postgres"
# Models are written HERE. It must differ from the source schema (tpch),
# otherwise a model named e.g. "customer" replaces the raw source table.
POSTGRES_SCHEMA="dbt"

if [[ -f "${SCRIPT_DIR}/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "${SCRIPT_DIR}/.env"
  set +a
fi

# Strip a leading https:// from the host, a common copy-paste mistake
DATABRICKS_HOST="${DATABRICKS_HOST#https://}"; DATABRICKS_HOST="${DATABRICKS_HOST%/}"

HAS_DATABRICKS="no"
if [[ -n "${DATABRICKS_HOST}" && -n "${DATABRICKS_HTTP_PATH}" && -n "${DATABRICKS_TOKEN}" ]]; then
  HAS_DATABRICKS="yes"
elif [[ -n "${DATABRICKS_HOST}${DATABRICKS_HTTP_PATH}${DATABRICKS_TOKEN}" ]]; then
  echo "Error: incomplete Databricks settings in .env." >&2
  echo "Set DATABRICKS_HOST, DATABRICKS_HTTP_PATH and DATABRICKS_TOKEN." >&2
  exit 1
fi

# Expand a leading ~ in the key path, in case it was quoted in .env
if [[ "${SNOWFLAKE_PRIVATE_KEY_PATH}" == "~/"* ]]; then
  SNOWFLAKE_PRIVATE_KEY_PATH="${HOME}/${SNOWFLAKE_PRIVATE_KEY_PATH#\~/}"
fi

HAS_SNOWFLAKE="no"; SNOWFLAKE_AUTH=""
if [[ -n "${SNOWFLAKE_ACCOUNT}" && -n "${SNOWFLAKE_USER}" ]]; then
  if [[ -n "${SNOWFLAKE_PRIVATE_KEY_PATH}" ]]; then
    HAS_SNOWFLAKE="yes"; SNOWFLAKE_AUTH="key-pair"
    if [[ ! -f "${SNOWFLAKE_PRIVATE_KEY_PATH}" ]]; then
      echo "Warning: the Snowflake private key is missing:" >&2
      echo "  ${SNOWFLAKE_PRIVATE_KEY_PATH}" >&2
      echo "  See docs/setup_instructions.md to create the key pair." >&2
    fi
  elif [[ -n "${SNOWFLAKE_PASSWORD}" ]]; then
    HAS_SNOWFLAKE="yes"; SNOWFLAKE_AUTH="password"
  fi
fi

# Pick a sensible default target if the user did not ask for one
if [[ -z "${DEFAULT_TARGET}" ]]; then
  DEFAULT_TARGET="postgres"
  [[ "${HAS_DATABRICKS}" == "yes" ]] && DEFAULT_TARGET="databricks"
fi
if [[ "${DEFAULT_TARGET}" == "databricks" && "${HAS_DATABRICKS}" == "no" ]]; then
  echo "Error: --target databricks needs Databricks credentials in .env." >&2
  echo "Copy .env.example to .env and fill in the Databricks values." >&2
  exit 1
fi
if [[ "${DEFAULT_TARGET}" == "snowflake" && "${HAS_SNOWFLAKE}" == "no" ]]; then
  echo "Error: --target snowflake needs Snowflake credentials in .env." >&2
  echo "Set SNOWFLAKE_ACCOUNT, SNOWFLAKE_USER and SNOWFLAKE_PRIVATE_KEY_PATH." >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Collect the profile names to write
# ---------------------------------------------------------------------------
NAMES=("dbt_academy" "covid")
if [[ ${#EXTRA_NAMES[@]} -gt 0 ]]; then
  NAMES+=("${EXTRA_NAMES[@]}")
fi

while IFS= read -r project_file; do
  discovered="$(python3 -c 'import sys, yaml; print((yaml.safe_load(open(sys.argv[1])) or {}).get("profile", ""))' "${project_file}")"
  [[ -n "${discovered}" ]] && NAMES+=("${discovered}")
done < <(find "${SCRIPT_DIR}" -name dbt_project.yml -not -path '*/target/*' \
  -not -path '*/dbt_packages/*' -not -path '*/.git/*' \
  -not -path '*/.venv/*' -not -path '*/venv/*' 2>/dev/null)

UNIQUE_NAMES=()
for name in "${NAMES[@]}"; do
  [[ -z "${name}" ]] && continue
  seen="no"
  for kept in "${UNIQUE_NAMES[@]+"${UNIQUE_NAMES[@]}"}"; do
    [[ "${kept}" == "${name}" ]] && seen="yes" && break
  done
  [[ "${seen}" == "no" ]] && UNIQUE_NAMES+=("${name}")
done

# ---------------------------------------------------------------------------
# Write ~/.dbt/profiles.yml
# ---------------------------------------------------------------------------
yaml_string() {
  local value
  value="$(printf '%s' "$1" | sed "s/'/''/g")"
  printf "'%s'" "$value"
}

emit_profile() {
  local profile_name="$1"
  echo "$(yaml_string "${profile_name}"):"
  echo "  target: ${DEFAULT_TARGET}"
  echo "  outputs:"
  cat << EOF
    postgres:
      type: postgres
      host: $(yaml_string "${POSTGRES_HOST}")
      port: ${POSTGRES_PORT}
      user: $(yaml_string "${POSTGRES_USER}")
      password: $(yaml_string "${POSTGRES_PASSWORD}")
      dbname: $(yaml_string "${POSTGRES_DBNAME}")
      schema: $(yaml_string "${POSTGRES_SCHEMA}")
      threads: 4
EOF
  if [[ "${HAS_DATABRICKS}" == "yes" ]]; then
    cat << EOF
    databricks:
      type: databricks
      host: $(yaml_string "${DATABRICKS_HOST}")
      http_path: $(yaml_string "${DATABRICKS_HTTP_PATH}")
      token: $(yaml_string "${DATABRICKS_TOKEN}")
      catalog: $(yaml_string "${DATABRICKS_CATALOG}")
      schema: $(yaml_string "${DATABRICKS_SCHEMA}")
      threads: 4
EOF
  fi
  if [[ "${HAS_SNOWFLAKE}" == "yes" ]]; then
    cat << EOF
    snowflake:
      type: snowflake
      account: $(yaml_string "${SNOWFLAKE_ACCOUNT}")
      user: $(yaml_string "${SNOWFLAKE_USER}")
EOF
    if [[ "${SNOWFLAKE_AUTH}" == "key-pair" ]]; then
      echo "      private_key_path: $(yaml_string "${SNOWFLAKE_PRIVATE_KEY_PATH}")"
      [[ -n "${SNOWFLAKE_PRIVATE_KEY_PASSPHRASE}" ]] && \
        echo "      private_key_passphrase: $(yaml_string "${SNOWFLAKE_PRIVATE_KEY_PASSPHRASE}")"
    else
      # Password sign-in for dbt stops working on 2026-08-31. Use key-pair.
      echo "      password: $(yaml_string "${SNOWFLAKE_PASSWORD}")"
      echo "      authenticator: username_password_mfa"
    fi
    [[ -n "${SNOWFLAKE_ROLE}" ]] && echo "      role: $(yaml_string "${SNOWFLAKE_ROLE}")"
    cat << EOF
      warehouse: $(yaml_string "${SNOWFLAKE_WAREHOUSE}")
      database: $(yaml_string "${SNOWFLAKE_DATABASE}")
      schema: $(yaml_string "${SNOWFLAKE_SCHEMA}")
      threads: 4
EOF
  fi
}
if [[ -e "${VISIBLE_PROFILE}" && ! -L "${VISIBLE_PROFILE}" && ! "${VISIBLE_PROFILE}" -ef "${PROFILES_PATH}" ]]; then
  echo "Error: ${VISIBLE_PROFILE} already exists. Move it aside before rerunning this script." >&2
  exit 1
fi
mkdir -p "$(dirname "${PROFILES_PATH}")"
{
  echo "# Generated by create_profiles.sh. Re-run that script to regenerate."
  echo "# Do not edit by hand: dbt init may overwrite this file."
  for name in "${UNIQUE_NAMES[@]}"; do
    emit_profile "${name}"
  done
} > "${PROFILES_PATH}"
chmod 600 "${PROFILES_PATH}"
PROFILE_ABSOLUTE_PATH="$(cd "$(dirname "${PROFILES_PATH}")" && pwd)/profiles.yml"
if [[ "${VISIBLE_PROFILE}" != "${PROFILE_ABSOLUTE_PATH}" ]]; then
  ln -sfn "${PROFILE_ABSOLUTE_PATH}" "${VISIBLE_PROFILE}"
fi

# ---------------------------------------------------------------------------
# Write the [academy] profile in ~/.databrickscfg for the VS Code extension.
# Any other profile in that file is kept as it is.
# ---------------------------------------------------------------------------
if [[ "${HAS_DATABRICKS}" == "yes" ]]; then
  mkdir -p "$(dirname "${DATABRICKS_CFG}")"
  tmp_cfg="$(mktemp)"
  if [[ -f "${DATABRICKS_CFG}" ]]; then
    # Drop an existing [academy] section, keep everything else
    awk 'BEGIN{skip=0} /^\[/{skip=($0=="[academy]")} !skip' "${DATABRICKS_CFG}" \
      | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}' > "${tmp_cfg}"
    echo "" >> "${tmp_cfg}"
  fi
  cat >> "${tmp_cfg}" << EOF
[academy]
host  = https://${DATABRICKS_HOST}
token = ${DATABRICKS_TOKEN}
EOF
  mv "${tmp_cfg}" "${DATABRICKS_CFG}"
  chmod 600 "${DATABRICKS_CFG}"
fi

# ---------------------------------------------------------------------------
# Report
# ---------------------------------------------------------------------------
echo "Wrote ${PROFILES_PATH}"
echo "Open profiles.yml in the repository Explorer to view the dbt connection settings."
echo "Profiles: ${UNIQUE_NAMES[*]}"
echo "Default target: ${DEFAULT_TARGET}"
echo "Targets in each profile:"
echo "  postgres    ${POSTGRES_USER}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DBNAME}, models -> schema ${POSTGRES_SCHEMA}"
if [[ "${HAS_DATABRICKS}" == "yes" ]]; then
  echo "  databricks  ${DATABRICKS_HOST}, models -> ${DATABRICKS_CATALOG}.${DATABRICKS_SCHEMA}"
  echo "Wrote the [academy] profile to ${DATABRICKS_CFG} for the VS Code extension."
else
  echo "  databricks  (not written: no Databricks credentials in .env)"
fi
if [[ "${HAS_SNOWFLAKE}" == "yes" ]]; then
  echo "  snowflake   ${SNOWFLAKE_ACCOUNT} as ${SNOWFLAKE_USER} (${SNOWFLAKE_AUTH}), models -> ${SNOWFLAKE_DATABASE}.${SNOWFLAKE_SCHEMA}"
  if [[ "${SNOWFLAKE_AUTH}" == "password" ]]; then
    echo "              WARNING: Snowflake stops password sign-in for dbt on 2026-08-31."
    echo "              Switch to key-pair: set SNOWFLAKE_PRIVATE_KEY_PATH in .env."
  fi
else
  echo "  snowflake   (not written: no Snowflake credentials in .env)"
fi
echo
echo "To create a new dbt project without losing these targets, run:"
echo "  dbt init <project_name> --skip-profile-setup"
echo "  ./create_profiles.sh          # picks up the new project"
echo "  dbt debug                     # inside the project folder"
