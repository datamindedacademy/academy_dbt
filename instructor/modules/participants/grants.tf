# Privileges are split in two: everything the whole class shares lives on one
# role, and each participant gets a personal role that inherits it and adds
# rights on their own schema only. That way nobody can drop a neighbour's models.

resource "snowflake_account_role" "shared" {
  name    = local.shared_role
  comment = "Privileges common to every participant of the Data Minded dbt course."
}

resource "snowflake_account_role" "participant" {
  for_each = local.participants

  name    = "${var.prefix}_${each.value}"
  comment = "Personal role of ${each.key}."
}

resource "snowflake_grant_account_role" "shared_to_participant" {
  for_each = local.participants

  role_name        = snowflake_account_role.shared.name
  parent_role_name = snowflake_account_role.participant[each.key].name
}

resource "snowflake_grant_account_role" "participant_to_user" {
  for_each = local.participants

  role_name = snowflake_account_role.participant[each.key].name
  user_name = snowflake_user.participant[each.key].name
}

# --- shared privileges ------------------------------------------------------

resource "snowflake_grant_privileges_to_account_role" "warehouse" {
  account_role_name = snowflake_account_role.shared.name
  privileges        = ["USAGE"]

  on_account_object {
    object_type = "WAREHOUSE"
    object_name = snowflake_warehouse.class.name
  }
}

resource "snowflake_grant_privileges_to_account_role" "database" {
  account_role_name = snowflake_account_role.shared.name
  privileges        = ["USAGE"]

  on_account_object {
    object_type = "DATABASE"
    object_name = snowflake_database.class.name
  }
}

# TPC-H lives in the SNOWFLAKE_SAMPLE_DATA share that ships with every account,
# so the course reads the same source tables as the Postgres and Databricks
# backends without loading a single row.
#
# "Ships with every account" is not quite a guarantee: freshly created accounts
# sometimes lack it. Look it up so the precondition below can say so plainly,
# rather than letting the grant fail with an opaque object-not-found error.
data "snowflake_databases" "sample_data" {
  like = "SNOWFLAKE_SAMPLE_DATA"

  # SHOW DATABASES alone needs no warehouse; DESCRIBE and SHOW PARAMETERS do.
  with_describe   = false
  with_parameters = false
}

resource "snowflake_grant_privileges_to_account_role" "sample_data" {
  account_role_name = snowflake_account_role.shared.name
  privileges        = ["IMPORTED PRIVILEGES"]

  on_account_object {
    object_type = "DATABASE"
    object_name = "SNOWFLAKE_SAMPLE_DATA"
  }

  lifecycle {
    precondition {
      condition     = length(data.snowflake_databases.sample_data.databases) > 0
      error_message = <<-EOT
        The SNOWFLAKE_SAMPLE_DATA database does not exist in this account, but
        grant_sample_data is true. The course reads its TPC-H source tables from
        it. Create it once, as ACCOUNTADMIN:

          CREATE DATABASE snowflake_sample_data FROM SHARE sfc_samples.sample_data;

        Then re-run the apply.
      EOT
    }
  }
}

# --- personal privileges ----------------------------------------------------

# ALL on their own schema lets dbt create, replace and drop models freely.
# Objects a participant creates are owned by their own role, so no future grants
# are needed on top of this.
resource "snowflake_grant_privileges_to_account_role" "own_schema" {
  for_each = local.participants

  account_role_name = snowflake_account_role.participant[each.key].name
  all_privileges    = true

  on_schema {
    schema_name = snowflake_schema.participant[each.key].fully_qualified_name
  }
}
