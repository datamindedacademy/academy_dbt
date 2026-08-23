# Cognito federation, for Snowsight sign-in only. dbt and IDEs authenticate with
# the programmatic access tokens in modules/participants/tokens.tf, which need no
# identity provider at all.

module "cognito" {
  source = "./modules/cognito"

  participants                = local.participants
  prefix                      = lower(replace(var.prefix, "_", "-"))
  email_domain                = var.participant_email_domain
  access_token_validity_hours = var.access_token_validity_hours

  snowflake_callback_urls = local.oidc_callback_urls
}

locals {
  # Underscores in an org or account name become hyphens in the URL.
  snowflake_account_url = "https://${lower(replace("${var.organization_name}-${var.account_name}", "_", "-"))}.snowflakecomputing.com"

  primary_oidc_callback = "${local.snowflake_account_url}/oauth2/oidc/callback"

  # Snowflake advertises several hostnames and picks among them; Cognito compares
  # redirect_uri byte for byte and answers a miss with `redirect_mismatch`.
  # OIDC_REDIRECT_URIS is read-only, so read the real list with
  # DESC SECURITY INTEGRATION and put the extras in extra_oidc_callback_urls.
  oidc_callback_urls = distinct(concat([local.primary_oidc_callback], var.extra_oidc_callback_urls))
}

# --- Snowsight: browser sign-in ----------------------------------------------
#
# The provider still has no OIDC integration resource (checked at v2.20.0), so
# this drops to raw SQL. snowflake_execute recreates on any change to `execute`
# and runs `revert` on destroy.
#
# Snowflake discovers the authorize, token and JWKS endpoints from the issuer's
# .well-known/openid-configuration, which is why the hosted UI domain has to
# exist before this runs.
#
# The client secret is interpolated into `execute`, so it lands in state in
# cleartext -- one more reason to destroy the environment after a course.
resource "snowflake_execute" "cognito_oidc" {
  execute = <<-SQL
    CREATE OR REPLACE SECURITY INTEGRATION ${var.prefix}_COGNITO_SNOWSIGHT
      TYPE = OIDC
      ENABLED = TRUE
      OIDC_PROVIDER = 'CUSTOM'
      OIDC_ISSUER = '${module.cognito.issuer}'
      OIDC_CLIENT_ID = '${module.cognito.client_id}'
      OIDC_CLIENT_SECRET = '${module.cognito.client_secret}'
      -- email -> EMAIL_ADDRESS looks more natural and does not resolve a user,
      -- even with a matching, unique EMAIL. Fails as INCORRECT_USERNAME_PASSWORD.
      OIDC_TOKEN_USER_MAPPING_CLAIM = 'cognito:username'
      OIDC_SNOWFLAKE_USER_MAPPING_ATTRIBUTE = 'LOGIN_NAME'
      OIDC_LOGIN_PAGE_LABEL = '${var.snowsight_login_label}'
      COMMENT = 'Snowsight sign-in for course participants, federated to Cognito.'
  SQL

  revert = "DROP SECURITY INTEGRATION IF EXISTS ${var.prefix}_COGNITO_SNOWSIGHT"

  query = "SHOW INTEGRATIONS LIKE '${var.prefix}_COGNITO_SNOWSIGHT'"
}
