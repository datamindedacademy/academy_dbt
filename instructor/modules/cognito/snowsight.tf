# Snowflake's OIDC integration refuses to be created without OIDC_CLIENT_SECRET,
# so this client is confidential.

# Cognito only publishes an authorization endpoint once the pool has a domain,
# and Snowflake discovers that endpoint from the issuer's
# .well-known/openid-configuration. Without this, discovery yields no authorize
# URL and the browser flow cannot start.
resource "aws_cognito_user_pool_domain" "hosted_ui" {
  # Must be unique across all of AWS in the region, hence the pool id.
  domain       = "${var.prefix}-${lower(replace(aws_cognito_user_pool.participants.id, "_", "-"))}"
  user_pool_id = aws_cognito_user_pool.participants.id
}

resource "aws_cognito_user_pool_client" "snowsight" {
  name         = "${var.prefix}-snowsight"
  user_pool_id = aws_cognito_user_pool.participants.id

  generate_secret = true

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["openid", "email", "profile"]
  supported_identity_providers         = ["COGNITO"]

  callback_urls = var.snowflake_callback_urls

  explicit_auth_flows = ["ALLOW_REFRESH_TOKEN_AUTH"]

  access_token_validity  = var.access_token_validity_hours
  id_token_validity      = var.access_token_validity_hours
  refresh_token_validity = 1

  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }
}
