locals {
  # Snowflake identifiers are upper-case and cannot contain punctuation unless
  # quoted:  "grace.hopper" -> GRACE_HOPPER
  participants = {
    for name in var.participants :
    name => upper(replace(name, "/[^a-zA-Z0-9]/", "_"))
  }

  database_name  = "${var.prefix}_DB"
  warehouse_name = "${var.prefix}_WH"
  shared_role    = "${var.prefix}_STUDENT"

  # One object instead of five inputs on every module instance.
  shared = {
    prefix         = var.prefix
    database       = snowflake_database.class.name
    warehouse      = snowflake_warehouse.class.name
    student_role   = snowflake_account_role.shared.name
    network_policy = snowflake_network_policy.participants.name
  }
}
