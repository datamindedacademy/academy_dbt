#!/usr/bin/env bash
# Writes one folder per participant under out/: a .env for their codespace and a
# README.txt telling them what to do with it.
#
#   ./scripts/render_credentials.sh [-o DIR]
#
# Needs jq. out/ is gitignored; delete it once handed out.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "${SCRIPT_DIR}")"
OUT_DIR="${ROOT_DIR}/out"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -o|--out) OUT_DIR="${2:?-o needs a directory}"; shift 2 ;;
    -h|--help) sed -n '2,7p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Error: unknown argument '$1'. Use --help." >&2; exit 1 ;;
  esac
done

command -v jq >/dev/null || { echo "Error: jq is required." >&2; exit 1; }

if command -v tofu >/dev/null; then
  TF=tofu
elif command -v terraform >/dev/null; then
  TF=terraform
else
  echo "Error: neither tofu nor terraform found on PATH." >&2
  exit 1
fi

cd "${ROOT_DIR}"

CREDENTIALS="$("${TF}" output -json credentials)"
PASSWORDS="$("${TF}" output -json participant_passwords)"
ACCOUNT_URL="$("${TF}" output -raw account_url)"
if [[ -z "${CREDENTIALS}" || "${CREDENTIALS}" == "null" || "${CREDENTIALS}" == "{}" ]]; then
  echo "Error: the 'credentials' output is empty. Run '${TF} apply' first." >&2
  exit 1
fi

mkdir -p "${OUT_DIR}"
chmod 700 "${OUT_DIR}"

count=0
while IFS= read -r participant; do
  entry="$(jq -c --arg p "${participant}" '.[$p]' <<<"${CREDENTIALS}")"

  account="$(jq -r '.account'     <<<"${entry}")"
  user="$(jq -r '.user'           <<<"${entry}")"
  role="$(jq -r '.role'           <<<"${entry}")"
  warehouse="$(jq -r '.warehouse' <<<"${entry}")"
  database="$(jq -r '.database'   <<<"${entry}")"
  schema="$(jq -r '.schema'       <<<"${entry}")"
  token="$(jq -r '.token'         <<<"${entry}")"
  password="$(jq -r --arg p "${participant}" '.[$p]' <<<"${PASSWORDS}")"

  dir="${OUT_DIR}/${participant}"
  mkdir -p "${dir}"
  chmod 700 "${dir}"

  {
    echo "# Snowflake credentials for ${participant} - do not share."
    echo "SNOWFLAKE_ACCOUNT=${account}"
    echo "SNOWFLAKE_USER=${user}"
    echo "SNOWFLAKE_ROLE=${role}"
    echo "SNOWFLAKE_WAREHOUSE=${warehouse}"
    echo "SNOWFLAKE_DATABASE=${database}"
    echo "SNOWFLAKE_SCHEMA=${schema}"
    echo "# Access token; goes where a password would."
    # Single-quoted: create_profiles.sh sources this file.
    echo "SNOWFLAKE_PASSWORD='${token//\'/\'\\\'\'}'"
  } > "${dir}/.env"
  chmod 600 "${dir}/.env"

  {
    echo "Snowflake access for ${participant}"
    echo
    echo "  user      ${user}"
    echo "  database  ${database}"
    echo "  schema    ${schema}   <- your models go here"
    echo "  warehouse ${warehouse}  (shared with the class)"
    echo
    echo "The TPC-H source tables are in SNOWFLAKE_SAMPLE_DATA.TPCH_SF1."
    echo
    echo "1. dbt and the Snowflake VS Code extension"
    echo
    echo "   Copy the .env from this folder into the repository root of your"
    echo "   codespace, then run:"
    echo
    echo "     ./create_profiles.sh"
    echo "     dbt debug --target snowflake"
    echo
    echo "   That also sets up the Snowflake extension, so you can run SQL in"
    echo "   the editor. Nothing expires during the course."
    echo
    echo "2. The Snowsight web UI"
    echo
    echo "     ${ACCOUNT_URL}"
    echo
    echo "   Click the \"Academy login\" button -- do not type into the username"
    echo "   and password fields, your Snowflake user has no password of its"
    echo "   own. Then sign in with:"
    echo
    echo "     username  ${participant}"
    echo "     password  ${password}"
  } > "${dir}/README.txt"
  chmod 600 "${dir}/README.txt"

  count=$((count + 1))
done < <(jq -r 'keys[]' <<<"${CREDENTIALS}")

echo "Wrote credentials for ${count} participant(s) to ${OUT_DIR}"
echo "Hand them out, then delete the folder:  rm -rf ${OUT_DIR}"
