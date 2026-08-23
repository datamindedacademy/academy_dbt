# Shared compute and storage for the class. One XSMALL for everybody: measured at
# 60 concurrent statements (15 participants x dbt's 4 threads) it queued for
# 0.3s and averaged 0.1s execution against TPC-H SF1. Multi-cluster would be the
# usual answer to concurrency, but it needs Enterprise Edition.

resource "snowflake_warehouse" "class" {
  name           = local.warehouse_name
  warehouse_size = var.warehouse_size
  auto_suspend   = 60 # participants idle a lot; keep the bill flat
  auto_resume    = "true"

  # Default is two days; one runaway query would stall the whole class.
  statement_timeout_in_seconds = 600
  comment                      = "Shared warehouse for the Data Minded dbt course."
}

resource "snowflake_database" "class" {
  name    = local.database_name
  comment = "Data Minded dbt course. Each participant owns one schema here."
}

