# Shared compute and storage for the class. One warehouse for everybody: the
# course is read-heavy against TPC-H SF1 and a shared XSMALL keeps the bill flat.

resource "snowflake_warehouse" "class" {
  name           = local.warehouse_name
  warehouse_size = var.warehouse_size
  auto_suspend   = 60 # participants idle a lot; keep the bill flat
  auto_resume    = "true"
  comment        = "Shared warehouse for the Data Minded dbt course."
}

resource "snowflake_database" "class" {
  name    = local.database_name
  comment = "Data Minded dbt course. Each participant owns one schema here."
}

# One schema per participant. dbt writes models here, so the participant's role
# needs full rights on it (see grants.tf).
resource "snowflake_schema" "participant" {
  for_each = local.participants

  database = snowflake_database.class.name
  name     = each.value
  comment  = "Workspace for ${each.key}."

  # Participants will drop and recreate models constantly; a day of Time Travel
  # is enough and keeps storage cost negligible.
  data_retention_time_in_days = 1
}
