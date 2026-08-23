output "credentials" {
  description = "Connection settings and access token per participant, keyed by the name in participants.yaml. Rendered into a handout by scripts/render_credentials.sh."
  sensitive   = true

  value = {
    for name, id in local.participants : name => {
      account = var.account_identifier
      # The LOGIN_NAME, not the object name: programmatic access tokens
      # authenticate against LOGIN_NAME, and it is also the Cognito username, so
      # participants have one username for both dbt and Snowsight.
      user      = snowflake_user.participant[name].login_name
      role      = snowflake_account_role.participant[name].name
      warehouse = snowflake_warehouse.class.name
      database  = snowflake_database.class.name
      schema    = snowflake_schema.participant[name].name

      # What participants put in their IDE and in dbt, in place of a password.
      token = snowflake_user_programmatic_access_token.participant[name].token
    }
  }
}

output "participant_roles" {
  description = "Snowflake account role per participant. Feeds the cognito module, which stamps it into each user's custom:snowflake_role so the Lambda can emit the matching session:role scope."
  value       = { for name, id in local.participants : name => snowflake_account_role.participant[name].name }
}

output "database_name" {
  value = snowflake_database.class.name
}

output "warehouse_name" {
  value = snowflake_warehouse.class.name
}
