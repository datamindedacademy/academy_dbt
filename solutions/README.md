# Solutions

Solution SQL for every exercise, written for **Databricks** (catalog
`samples`, schema `tpch` — the built-in TPC-H dataset).

## How to run

- **Databricks extension / SQL editor:** open a `.sql` file and run the
  statements against the Serverless Starter Warehouse.
- **On Postgres** (the codespace database): remove the `samples.` prefix —
  the tables live in schema `tpch` there. The queries are otherwise identical.

## Layout

- [`sql/`](sql/) — one file per SQL exercise, numbered like the exercises.
- [`dbt/`](dbt/) — the dbt exercises whose solution is SQL, in *compiled* form
  (plain SQL, runnable directly), with the original dbt/Jinja code in comments.
  Exercises whose solution is a command or YAML (1, 3, 4, 6, 10, 11) are
  answered in [`dbt/README.md`](dbt/README.md).

Spoiler warning: try the exercises first.
