locals {
  # Derived here, exposed as outputs. Cognito consumes those rather than
  # recomputing: two derivations that disagree break login opaquely.
  email        = "${var.name}@${var.email_domain}"
  display_name = title(replace(replace(var.name, ".", " "), "_", " "))
}

resource "snowflake_schema" "this" {
  database = var.shared.database
  name     = var.identifier
  comment  = "Workspace for ${var.name}."

  data_retention_time_in_days = 1
}

resource "snowflake_account_role" "this" {
  name    = "${var.shared.prefix}_${var.identifier}"
  comment = "Personal role of ${var.name}."
}

# No password and no key: the token below and Cognito are the only ways in.
resource "snowflake_user" "this" {
  name         = "${var.shared.prefix}_${var.identifier}"
  login_name   = var.name
  email        = local.email
  display_name = local.display_name
  comment      = "Data Minded dbt course participant ${var.name}."

  network_policy = var.shared.network_policy

  default_warehouse = var.shared.warehouse
  default_role      = snowflake_account_role.this.name
  default_namespace = "${var.shared.database}.${snowflake_schema.this.name}"
}

resource "snowflake_grant_account_role" "student" {
  role_name        = var.shared.student_role
  parent_role_name = snowflake_account_role.this.name
}

resource "snowflake_grant_account_role" "to_user" {
  role_name = snowflake_account_role.this.name
  user_name = snowflake_user.this.name
}

# Objects they create are owned by their own role, so no future grants needed.
resource "snowflake_grant_privileges_to_account_role" "own_schema" {
  account_role_name = snowflake_account_role.this.name
  all_privileges    = true

  on_schema {
    schema_name = snowflake_schema.this.fully_qualified_name
  }
}

resource "snowflake_user_programmatic_access_token" "this" {
  user = snowflake_user.this.name
  name = "DBT"

  role_restriction = snowflake_account_role.this.name

  # No days_to_expiry: the account PAT policy default applies (15 days).
  comment = "dbt and IDE access for ${var.name}."

  depends_on = [snowflake_grant_account_role.to_user]
}
