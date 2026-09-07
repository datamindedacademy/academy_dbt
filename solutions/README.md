# Solutions

Solution SQL for every exercise, written for **Databricks** (catalog
`samples`, schema `tpch` — the built-in TPC-H dataset).

## Run the complete data products

Use [the complete dbt project](dbt/dataproducts/) and [the SQL pipeline](sql_pipeline/) to build the same eight models.
The [SQL pipeline guide](sql_pipeline/) gives the commands to run and compare both versions.
No exercise edits are required.

## Run the SQL examples

- **SQLTools with the Databricks driver / Databricks SQL editor:** select a query and run it against your SQL warehouse.
- **Databricks extension:** use it for Databricks notebooks and jobs. It does not execute these dbt models against a SQL warehouse.
- **On Postgres** (the codespace database): remove the `samples.` prefix —
  the tables live in schema `tpch` there. The data-product project targets Databricks only.

See [VS Code setup](../docs/setup_instructions.md#sql-and-dbt-in-vs-code).

## Layout

- [`sql/`](sql/) — one file per SQL exercise, numbered like the exercises.
- [`sql_pipeline/`](sql_pipeline/) — complete SQL statements, data checks, and the ordered Python runner.
- [`dbt/dataproducts/`](dbt/dataproducts/) — a complete dbt project with source-aligned and consumer-aligned products.
- [`dbt/`](dbt/) — the dbt exercises whose solution is SQL, in *compiled* form
  (plain SQL, runnable directly), with the original dbt/Jinja code in comments.
  Exercises whose solution is a command or YAML (1, 3, 4, 6, 10, 11) are
  answered in [`dbt/README.md`](dbt/README.md).

Run the supplied examples directly, or use the exercises for optional practice.
