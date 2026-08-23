#!/usr/bin/env bash
# Generates the SQL that creates a course account and prepares it for Terraform.
#
# This prints SQL; it never connects to Snowflake. The first block needs ORGADMIN
# in your organization's admin account, the second needs ACCOUNTADMIN inside the
# account you just created. Read both before running them.
#
# It also generates the RSA key pair for the Terraform service user, because
# stripping the PEM envelope for RSA_PUBLIC_KEY is easy to get wrong by hand.
#
# Usage:
#   ./scripts/bootstrap_account.sh                       # defaults, see below
#   ./scripts/bootstrap_account.sh --account winterschool --region aws_eu_central_1
#   ./scripts/bootstrap_account.sh --edition ENTERPRISE
#
# Defaults: account summerschool, region aws_eu_west_1, edition STANDARD.
set -euo pipefail

ACCOUNT="summerschool"
# Empty means: omit REGION from CREATE ACCOUNT, so Snowflake places the account
# in the same region as the org admin account running the statement. That is
# usually what you want, and it avoids guessing at a choice you cannot undo.
REGION=""
EDITION="STANDARD"
ADMIN_NAME=""
EMAIL=""
KEY_DIR="${HOME}/.snowflake"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -a|--account)    ACCOUNT="${2:?--account needs a value}"; shift 2 ;;
    -r|--region)     REGION="${2:?--region needs a value}"; shift 2 ;;
    -e|--edition)    EDITION="${2:?--edition needs a value}"; shift 2 ;;
    -n|--admin-name) ADMIN_NAME="${2:?--admin-name needs a value}"; shift 2 ;;
    -m|--email)      EMAIL="${2:?--email needs a value}"; shift 2 ;;
    -k|--key-dir)    KEY_DIR="${2:?--key-dir needs a value}"; shift 2 ;;
    -h|--help)       sed -n '2,17p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Error: unknown argument '$1'. Use --help." >&2; exit 1 ;;
  esac
done

case "${EDITION}" in
  STANDARD|ENTERPRISE|BUSINESS_CRITICAL) ;;
  *) echo "Error: --edition must be STANDARD, ENTERPRISE or BUSINESS_CRITICAL." >&2; exit 1 ;;
esac

[[ -n "${ADMIN_NAME}" ]] || { echo "Error: --admin-name is required (your Snowflake login for the new account)." >&2; exit 1; }
[[ -n "${EMAIL}" ]]      || { echo "Error: --email is required." >&2; exit 1; }

command -v openssl >/dev/null || { echo "Error: openssl is required." >&2; exit 1; }

# --- key pair for the Terraform service user --------------------------------

mkdir -p "${KEY_DIR}"
chmod 700 "${KEY_DIR}"
PRIVATE_KEY="${KEY_DIR}/${ACCOUNT}_tf.p8"
PUBLIC_KEY="${KEY_DIR}/${ACCOUNT}_tf.pub"

if [[ -f "${PRIVATE_KEY}" ]]; then
  echo "-- Reusing the existing key at ${PRIVATE_KEY}" >&2
else
  openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out "${PRIVATE_KEY}" 2>/dev/null
  chmod 600 "${PRIVATE_KEY}"
  openssl rsa -pubout -in "${PRIVATE_KEY}" -out "${PUBLIC_KEY}" 2>/dev/null
  chmod 644 "${PUBLIC_KEY}"
  echo "-- Generated a new key pair at ${PRIVATE_KEY}" >&2
fi

# RSA_PUBLIC_KEY wants the bare base64 body, without the PEM envelope.
PUBLIC_KEY_BODY="$(grep -v -- '-----' "${PUBLIC_KEY}" | tr -d '\n')"

# Snowflake needs 8+ chars with upper, lower and a digit; base64 of 24 random
# bytes satisfies that and contains no quote characters to escape.
ADMIN_PASSWORD="$(openssl rand -base64 24)"

# --- the SQL ----------------------------------------------------------------

if [[ -n "${REGION}" ]]; then
  REGION_CLAUSE=$'\n  REGION               = \''"${REGION}"$'\''
  REGION_NOTE="Confirm '${REGION}' before running this."
else
  REGION_CLAUSE=""
  REGION_NOTE="No REGION given, so the account lands in the same region as the
-- account you run this from. Add --region to place it elsewhere."
fi

cat <<EOF
-- ===========================================================================
-- STEP 1  Run as ORGADMIN, in your organization's admin account.
--
-- REGION IS PERMANENT. Edition and name can be changed later with
-- ALTER ACCOUNT; region cannot. ${REGION_NOTE}
-- ===========================================================================

USE ROLE ORGADMIN;

CREATE ACCOUNT ${ACCOUNT}
  ADMIN_NAME           = '${ADMIN_NAME}'
  ADMIN_PASSWORD       = '${ADMIN_PASSWORD}'
  EMAIL                = '${EMAIL}'
  MUST_CHANGE_PASSWORD = FALSE
  EDITION              = ${EDITION}${REGION_CLAUSE}
  COMMENT              = 'Data Minded Academy course environments';

-- Note the account_url from here; it is how you sign in to the new account.
SHOW ACCOUNTS LIKE '${ACCOUNT}';

-- ===========================================================================
-- STEP 2  Run as ACCOUNTADMIN, inside the new '${ACCOUNT}' account.
-- ===========================================================================

USE ROLE ACCOUNTADMIN;

-- 2a. The course reads TPC-H from the sample data share. It is usually present
--     already; create it if SHOW returns nothing, otherwise the Terraform grant
--     on it fails.
SHOW DATABASES LIKE 'SNOWFLAKE_SAMPLE_DATA';
-- CREATE DATABASE snowflake_sample_data FROM SHARE sfc_samples.sample_data;

-- 2b. A service user for Terraform, so applies need no MFA prompt.
CREATE USER terraform
  TYPE           = SERVICE
  RSA_PUBLIC_KEY = '${PUBLIC_KEY_BODY}'
  COMMENT        = 'Terraform, manages course environments';

GRANT ROLE ACCOUNTADMIN TO USER terraform;

-- ===========================================================================
-- STEP 3  Back in instructor/, apply the module.
-- ===========================================================================
--
--   cp terraform.tfvars.example terraform.tfvars
--     organization_name = "<your org>"
--     account_name      = "${ACCOUNT}"
--     admin_user        = "TERRAFORM"
--     admin_role        = "ACCOUNTADMIN"
--
--   cp participants.yaml.example participants.yaml   # then edit it
--
--   export SNOWFLAKE_AUTHENTICATOR=SNOWFLAKE_JWT
--   export SNOWFLAKE_PRIVATE_KEY="\$(cat ${PRIVATE_KEY})"
--
--   tofu init && tofu plan && tofu apply
--   ./scripts/render_credentials.sh
EOF

cat >&2 <<EOF

-- ---------------------------------------------------------------------------
-- The admin password for '${ADMIN_NAME}' is in the SQL above, on stdout only.
-- Store it in your password manager now; this script does not keep it.
--
-- On first Snowsight sign-in Snowflake will ask you to enrol in MFA. That is
-- expected for a PERSON user and does not affect the Terraform service user,
-- which authenticates with the key pair.
-- ---------------------------------------------------------------------------
EOF
