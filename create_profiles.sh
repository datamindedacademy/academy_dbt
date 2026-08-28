#!/bin/bash
# Generates ~/.dbt/profiles.yml for the course, in your HOME directory, so that
# dbt, dbt init and the VS Code extensions all pick it up.
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
#   - the fallback names dbt_test and covid
#
# Re-run it any time. It is safe to run twice, and it repairs the file after
# `dbt init` has overwritten it.
#
# Usage:
#   ./create_profiles.sh                       # postgres is the default target
#   ./create_profiles.sh --target databricks   # databricks is the default target
#   ./create_profiles.sh --target snowflake    # snowflake is the default target
#   ./create_profiles.sh my_project            # also write a profile 'my_project'
#
# Then:
#   dbt debug                        # tests the default target
#   dbt debug --target databricks    # tests one specific target
#   dbt run --target databricks      # runs the project on that backend
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILES_PATH="${HOME}/.dbt/profiles.yml"
DATABRICKS_CFG="${HOME}/.databrickscfg"
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
NAMES=("dbt_test" "covid")
NAMES+=("${EXTRA_NAMES[@]+"${EXTRA_NAMES[@]}"}")

while IFS= read -r project_file; do
  discovered="$(sed -n 's/^profile:[[:space:]]*['"'"'"]\{0,1\}\([^'"'"'"]*\)['"'"'"]\{0,1\}[[:space:]]*$/\1/p' \
    "${project_file}" | head -1)"
  [[ -n "${discovered}" ]] && NAMES+=("${discovered}")
done < <(find "${SCRIPT_DIR}" -name dbt_project.yml -not -path '*/target/*' \
  -not -path '*/dbt_packages/*' -not -path '*/.git/*' 2>/dev/null)

UNIQUE_NAMES=()
for name in "${NAMES[@]}"; do
  seen="no"
  for kept in "${UNIQUE_NAMES[@]+"${UNIQUE_NAMES[@]}"}"; do
    [[ "${kept}" == "${name}" ]] && seen="yes" && break
  done
  [[ "${seen}" == "no" ]] && UNIQUE_NAMES+=("${name}")
done

# ---------------------------------------------------------------------------
# Write ~/.dbt/profiles.yml
# ---------------------------------------------------------------------------
emit_profile() {
  local profile_name="$1"
  echo "${profile_name}:"
  echo "  target: ${DEFAULT_TARGET}"
  echo "  outputs:"
  cat << EOF
    postgres:
      type: postgres
      host: ${POSTGRES_HOST}
      port: ${POSTGRES_PORT}
      user: ${POSTGRES_USER}
      password: ${POSTGRES_PASSWORD}
      dbname: ${POSTGRES_DBNAME}
      schema: ${POSTGRES_SCHEMA}
      threads: 4
EOF
  if [[ "${HAS_DATABRICKS}" == "yes" ]]; then
    cat << EOF
    databricks:
      type: databricks
      host: ${DATABRICKS_HOST}
      http_path: ${DATABRICKS_HTTP_PATH}
      token: ${DATABRICKS_TOKEN}
      catalog: ${DATABRICKS_CATALOG}
      schema: ${DATABRICKS_SCHEMA}
      threads: 4
EOF
  fi
  if [[ "${HAS_SNOWFLAKE}" == "yes" ]]; then
    cat << EOF
    snowflake:
      type: snowflake
      account: ${SNOWFLAKE_ACCOUNT}
      user: ${SNOWFLAKE_USER}
EOF
    if [[ "${SNOWFLAKE_AUTH}" == "key-pair" ]]; then
      echo "      private_key_path: ${SNOWFLAKE_PRIVATE_KEY_PATH}"
      [[ -n "${SNOWFLAKE_PRIVATE_KEY_PASSPHRASE}" ]] && \
        echo "      private_key_passphrase: ${SNOWFLAKE_PRIVATE_KEY_PASSPHRASE}"
    else
      # Password sign-in for dbt stops working on 2026-08-31. Use key-pair.
      echo "      password: ${SNOWFLAKE_PASSWORD}"
      echo "      authenticator: username_password_mfa"
    fi
    [[ -n "${SNOWFLAKE_ROLE}" ]] && echo "      role: ${SNOWFLAKE_ROLE}"
    cat << EOF
      warehouse: ${SNOWFLAKE_WAREHOUSE}
      database: ${SNOWFLAKE_DATABASE}
      schema: ${SNOWFLAKE_SCHEMA}
      threads: 4
EOF
  fi
}

mkdir -p "$(dirname "${PROFILES_PATH}")"
{
  echo "# Generated by create_profiles.sh. Re-run that script to regenerate."
  echo "# Do not edit by hand: dbt init may overwrite this file."
  for name in "${UNIQUE_NAMES[@]}"; do
    emit_profile "${name}"
  done
} > "${PROFILES_PATH}"
chmod 600 "${PROFILES_PATH}"

# ---------------------------------------------------------------------------
# Write the [academy] profile in ~/.databrickscfg for the VS Code extension.
# Any other profile in that file is kept as it is.
# ---------------------------------------------------------------------------
if [[ "${HAS_DATABRICKS}" == "yes" ]]; then
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
echo "  dbt init <project_name> --skip-profile-setup --skip-debug"
echo "  ./create_profiles.sh          # picks up the new project"
echo "  dbt debug                     # inside the project folder"
