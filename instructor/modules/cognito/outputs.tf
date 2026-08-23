data "aws_region" "current" {}

output "issuer" {
  description = "OIDC issuer URL. Snowflake discovers its endpoints from this and matches the token's iss claim against it."
  value       = "https://cognito-idp.${data.aws_region.current.name}.amazonaws.com/${aws_cognito_user_pool.participants.id}"
}

output "client_id" {
  description = "Confidential app client for Snowsight's browser flow."
  value       = aws_cognito_user_pool_client.snowsight.id
}

output "client_secret" {
  description = "Secret for that client, required by Snowflake's OIDC integration."
  sensitive   = true
  value       = aws_cognito_user_pool_client.snowsight.client_secret
}

output "participant_passwords" {
  description = "Snowsight sign-in password per participant."
  sensitive   = true
  value       = { for name, _ in var.participants : name => random_password.participant[name].result }
}
