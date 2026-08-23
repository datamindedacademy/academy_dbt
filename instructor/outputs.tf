output "credentials" {
  description = "Login credentials per participant. Render them with scripts/render_credentials.sh."
  sensitive   = true
  value       = module.participants.credentials
}

output "participant_passwords" {
  description = "Snowsight sign-in password per participant."
  sensitive   = true
  value       = module.cognito.participant_passwords
}

output "account_url" {
  description = "Where participants sign in to Snowsight."
  value       = local.snowflake_account_url
}
