output "credentials" {
  description = "Login credentials per participant. Render them with scripts/render_credentials.sh."
  sensitive   = true
  value       = module.participants.credentials
}

output "participants" {
  description = "The names read from participants.yaml, so you can check the file was picked up."
  value       = sort(tolist(local.participants))
}

output "cognito" {
  description = "Cognito endpoints and the Snowsight app client."
  value = {
    issuer        = module.cognito.issuer
    client_id     = module.cognito.client_id
    hosted_ui_url = module.cognito.hosted_ui_url
  }
}

output "participant_passwords" {
  description = "Snowsight sign-in password per participant."
  sensitive   = true
  value       = module.cognito.participant_passwords
}

output "database_name" {
  value = module.participants.database_name
}

output "warehouse_name" {
  value = module.participants.warehouse_name
}

output "account_url" {
  description = "Where participants sign in to Snowsight."
  value       = local.snowflake_account_url
}
