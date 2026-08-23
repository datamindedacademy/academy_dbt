#!/bin/bash
# Generates ~/.dbt/profiles.yml for the course.
#
# Every profile it writes gets a target per backend you have configured:
#   postgres    - the local database in the codespace (default)
#   databricks  - your Databricks Free Edition workspace (needs .env)
#   snowflake   - only if your instructor set the course up on Snowflake, and
#                 only when .env has the SNOWFLAKE_* settings they gave you
#
# It writes a profile for:
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
#   ./create_profiles.sh my_project            # also write a profile 'my_project'
#
# Then:
#   dbt debug                        # tests the default target
#   dbt debug --target databricks    # tests the databricks target
#   dbt run --target databricks      # runs the project on Databricks
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILES_PATH="${HOME}/.dbt/profiles.yml"
DEFAULT_TARGET="postgres"
EXTRA_NAMES=()

usage() {
  sed -n '2,28p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -t|--target)
      DEFAULT_TARGET="${2:-}"
      if [[ "${DEFAULT_TARGET}" != "postgres" && "${DEFAULT_TARGET}" != "databricks" && "${DEFAULT_TARGET}" != "snowflake" ]]; then
        echo "Error: --target must be 'postgres', 'databricks' or 'snowflake'." >&2
        exit 1
      fi
      shift 2
      ;;
    -h|--help) usage ;;
    -*) echo "Error: unknown option '$1'. Use --help." >&2; exit 1 ;;
    *) EXTRA_NAMES+=("$1"); shift ;;
  esac
done

# ---------------------------------------------------------------------------
# Load settings from .env (all optional except the Databricks credentials)
# ---------------------------------------------------------------------------
DATABRICKS_HOST=""
DATABRICKS_HTTP_PATH=""
DATABRICKS_TOKEN=""
DATABRICKS_CATALOG="workspace"
DATABRICKS_SCHEMA="dbt"
POSTGRES_HOST="db"
POSTGRES_PORT="5432"
POSTGRES_USER="postgres"
POSTGRES_PASSWORD="postgres"
POSTGRES_DBNAME="postgres"
# Models are written HERE. It must differ from the source schema (tpch),
# otherwise a model named e.g. "customer" replaces the raw source table.
POSTGRES_SCHEMA="dbt"
# Snowflake (only when your instructor runs the course on it)
SNOWFLAKE_ACCOUNT=""
SNOWFLAKE_USER=""
SNOWFLAKE_ROLE=""
SNOWFLAKE_WAREHOUSE=""
SNOWFLAKE_DATABASE=""
SNOWFLAKE_SCHEMA=""
# One of these decides how dbt authenticates; see docs/setup_instructions.md.
SNOWFLAKE_PRIVATE_KEY_PATH=""
SNOWFLAKE_PASSWORD=""

if [[ -f "${SCRIPT_DIR}/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "${SCRIPT_DIR}/.env"
  set +a
fi

# Strip a leading https:// from the host, a common copy-paste mistake
DATABRICKS_HOST="${DATABRICKS_HOST#https://}"
DATABRICKS_HOST="${DATABRICKS_HOST%/}"

HAS_DATABRICKS="no"
if [[ -n "${DATABRICKS_HOST}" && -n "${DATABRICKS_HTTP_PATH}" && -n "${DATABRICKS_TOKEN}" ]]; then
  HAS_DATABRICKS="yes"
fi

HAS_SNOWFLAKE="no"
if [[ -n "${SNOWFLAKE_ACCOUNT}" && -n "${SNOWFLAKE_USER}" && -n "${SNOWFLAKE_DATABASE}" ]] \
  && [[ -n "${SNOWFLAKE_PASSWORD}" || -n "${SNOWFLAKE_PRIVATE_KEY_PATH}" ]]; then
  HAS_SNOWFLAKE="yes"
fi

if [[ "${DEFAULT_TARGET}" == "databricks" && "${HAS_DATABRICKS}" == "no" ]]; then
  echo "Error: --target databricks needs Databricks credentials." >&2
  echo "Copy .env.example to .env and fill in the three values." >&2
  exit 1
fi

if [[ "${DEFAULT_TARGET}" == "snowflake" && "${HAS_SNOWFLAKE}" == "no" ]]; then
  echo "Error: --target snowflake needs the Snowflake settings in .env." >&2
  echo "Your instructor provides that file; the course only runs on Snowflake" >&2
  echo "if they set it up." >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Collect the profile names to write
# ---------------------------------------------------------------------------
NAMES=("dbt_test" "covid")
NAMES+=("${EXTRA_NAMES[@]+"${EXTRA_NAMES[@]}"}")

# Discover the profile name of every dbt project in this repository
while IFS= read -r project_file; do
  discovered="$(sed -n 's/^profile:[[:space:]]*['"'"'"]\{0,1\}\([^'"'"'"]*\)['"'"'"]\{0,1\}[[:space:]]*$/\1/p' \
    "${project_file}" | head -1)"
  [[ -n "${discovered}" ]] && NAMES+=("${discovered}")
done < <(find "${SCRIPT_DIR}" -name dbt_project.yml -not -path '*/target/*' \
  -not -path '*/dbt_packages/*' -not -path '*/.git/*' 2>/dev/null)

# Remove duplicates, keep the order
UNIQUE_NAMES=()
for name in "${NAMES[@]}"; do
  seen="no"
  for kept in "${UNIQUE_NAMES[@]+"${UNIQUE_NAMES[@]}"}"; do
    [[ "${kept}" == "${name}" ]] && seen="yes" && break
  done
  [[ "${seen}" == "no" ]] && UNIQUE_NAMES+=("${name}")
done

# ---------------------------------------------------------------------------
# Write the file
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
    if [[ -n "${SNOWFLAKE_PRIVATE_KEY_PATH}" ]]; then
      echo "      private_key_path: ${SNOWFLAKE_PRIVATE_KEY_PATH}"
    else
      # Also the field for a programmatic access token: a PAT is presented in
      # place of the password.
      echo "      password: ${SNOWFLAKE_PASSWORD}"
    fi
    cat << EOF
      role: ${SNOWFLAKE_ROLE}
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
# Also write ~/.snowflake/connections.toml, which the Snowflake VS Code
# extension reads, so the SQL exercises have a client inside the editor.
# ---------------------------------------------------------------------------
if [[ "${HAS_SNOWFLAKE}" == "yes" ]]; then
  if true; then
    CONNECTIONS_PATH="${HOME}/.snowflake/connections.toml"
    mkdir -p "$(dirname "${CONNECTIONS_PATH}")"
    {
      echo "# Generated by create_profiles.sh. Re-run that script to regenerate."
      echo "[academy]"
      echo "account = \"${SNOWFLAKE_ACCOUNT}\""
      echo "user = \"${SNOWFLAKE_USER}\""
      [[ -n "${SNOWFLAKE_ROLE}" ]] && echo "role = \"${SNOWFLAKE_ROLE}\""
      [[ -n "${SNOWFLAKE_WAREHOUSE}" ]] && echo "warehouse = \"${SNOWFLAKE_WAREHOUSE}\""
      echo "database = \"${SNOWFLAKE_DATABASE}\""
      [[ -n "${SNOWFLAKE_SCHEMA}" ]] && echo "schema = \"${SNOWFLAKE_SCHEMA}\""
      if [[ -n "${SNOWFLAKE_PRIVATE_KEY_PATH}" ]]; then
        echo "private_key_file = \"${SNOWFLAKE_PRIVATE_KEY_PATH}\""
      else
        # A programmatic access token goes in this field too: it replaces the
        # password rather than needing an authenticator of its own.
        echo "password = \"${SNOWFLAKE_PASSWORD}\""
      fi
    } > "${CONNECTIONS_PATH}"
    # Snowflake refuses to read this file if it is group- or world-readable.
    chmod 600 "${CONNECTIONS_PATH}"
    WROTE_CONNECTIONS="${CONNECTIONS_PATH}"
  fi
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
  echo "  databricks  ${DATABRICKS_HOST}, catalog ${DATABRICKS_CATALOG}, schema ${DATABRICKS_SCHEMA}"
else
  echo "  databricks  (not written: no .env file with credentials)"
  echo "              Copy .env.example to .env, fill it in, then re-run this script."
fi
if [[ "${HAS_SNOWFLAKE}" == "yes" ]]; then
  echo "  snowflake   ${SNOWFLAKE_ACCOUNT}, database ${SNOWFLAKE_DATABASE}, models -> schema ${SNOWFLAKE_SCHEMA}"
  if [[ -n "${SNOWFLAKE_PRIVATE_KEY_PATH}" ]]; then
    echo "              key pair: ${SNOWFLAKE_PRIVATE_KEY_PATH}"
  else
    echo "              access token or password from .env"
  fi
fi
if [[ -n "${WROTE_CONNECTIONS:-}" ]]; then
  echo
  echo "Wrote ${WROTE_CONNECTIONS} (connection 'academy')."
  echo "The Snowflake VS Code extension picks this up for the SQL exercises."
fi
echo
echo "To create a new dbt project without losing these targets, run:"
echo "  dbt init <project_name> --skip-profile-setup --skip-debug"
echo "  ./create_profiles.sh          # picks up the new project"
echo "  dbt debug                     # inside the project folder"
