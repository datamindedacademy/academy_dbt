# SQL & dbt — Self-Service Exercises

Welcome! This folder contains all the hands-on exercises of the Dataminded Academy
SQL & dbt course, restructured so you can work through them at your own pace.
No prior knowledge of SQL or dbt is required.

## How this course works

The course has two parts. Do them in order:

| Part | What you learn | Where |
|---|---|---|
| 1. SQL | Query a database: filter, join, aggregate, and structure queries | [`sql/`](sql/) |
| 2. dbt | Turn SQL queries into a tested, documented, maintainable data pipeline | [`dbt/`](dbt/) |

Each exercise lives in its own numbered folder and has a `README.md` with:

- **Goal** — what you will be able to do afterwards
- **Why this matters** — the reason this concept exists
- **Concepts** — a short explanation, enough to solve the exercise
- **Exercise** — the tasks themselves
- **Tips** — hints if you get stuck

## Setup (one time)

Follow the [setup instructions](../docs/setup_instructions.md#databricks-free-edition)
to create a codespace and a Databricks Free Edition workspace.
The codespace contains dbt. Your Databricks workspace contains the SQL warehouse.

Use the Databricks SQL editor for part 1.
Use the terminal in the codespace for part 2.
Postgres in the codespace is the backup.

## The dataset

The main course uses the **TPC-H** dataset: a fictional wholesale business with
customers, orders, parts, and suppliers. It is the "hello world" of relational
databases. The Databricks tables live in `samples.tpch`. The Postgres tables live in `tpch`.
The schema is explained in [`sql/README.md`](sql/README.md).

> **Note:** the Postgres sample data is small (150 customers,
> 1500 orders). If a query unexpectedly returns zero rows, your logic may still be
> correct — try relaxing a threshold to check.
