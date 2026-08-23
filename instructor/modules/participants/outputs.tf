output "credentials" {
  description = "Connection settings and access token per participant, keyed by the name in participants.yaml."
  sensitive   = true

  value = {
    for name, m in module.participant : name => {
      account   = var.account_identifier
      user      = m.login_name
      role      = m.role
      warehouse = snowflake_warehouse.class.name
      database  = snowflake_database.class.name
      schema    = m.schema
      token     = m.token
    }
  }
}

output "participant_emails" {
  description = "Course-scoped address per participant, derived once in the participant module. The cognito module consumes this rather than deriving it again."
  value       = { for name, m in module.participant : name => m.email }
}
