output "email" {
  value = local.email
}

output "login_name" {
  value = snowflake_user.this.login_name
}

output "role" {
  value = snowflake_account_role.this.name
}

output "schema" {
  value = snowflake_schema.this.name
}

output "token" {
  value = snowflake_user_programmatic_access_token.this.token
}
