module "cognito" {
  source = "./modules/cognito"

  participants                = module.participants.participant_emails
  prefix                      = lower(replace(var.prefix, "_", "-"))
  access_token_validity_hours = var.access_token_validity_hours

  snowflake_callback_urls = local.oidc_callback_urls
}

locals {
  # Underscores in an org or account name become hyphens in the URL.
  snowflake_account_url = "https://${lower(replace("${var.organization_name}-${var.account_name}", "_", "-"))}.snowflakecomputing.com"

  primary_oidc_callback = "${local.snowflake_account_url}/oauth2/oidc/callback"

  oidc_callback_urls = distinct(concat([local.primary_oidc_callback], var.extra_oidc_callback_urls))
}

# --- Snowsight: browser sign-in ----------------------------------------------
#
# No OIDC integration resource in the provider (checked at v2.20.0).
#
resource "snowflake_execute" "cognito_oidc" {
  execute = <<-SQL
    CREATE OR REPLACE SECURITY INTEGRATION ${var.prefix}_COGNITO_SNOWSIGHT
      TYPE = OIDC
      ENABLED = TRUE
      OIDC_PROVIDER = 'CUSTOM'
      OIDC_ISSUER = '${module.cognito.issuer}'
      OIDC_CLIENT_ID = '${module.cognito.client_id}'
      OIDC_CLIENT_SECRET = '${module.cognito.client_secret}'
      -- email -> EMAIL_ADDRESS resolves nobody, even when the emails match.
      OIDC_TOKEN_USER_MAPPING_CLAIM = 'cognito:username'
      OIDC_SNOWFLAKE_USER_MAPPING_ATTRIBUTE = 'LOGIN_NAME'
      OIDC_LOGIN_PAGE_LABEL = '${var.snowsight_login_label}'
      COMMENT = 'Snowsight sign-in for course participants, federated to Cognito.'
  SQL

  revert = "DROP SECURITY INTEGRATION IF EXISTS ${var.prefix}_COGNITO_SNOWSIGHT"

  query = "SHOW INTEGRATIONS LIKE '${var.prefix}_COGNITO_SNOWSIGHT'"
}
