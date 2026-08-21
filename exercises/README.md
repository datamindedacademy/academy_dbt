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

You work in a preconfigured cloud environment (a GitHub Codespace) that contains
everything: a Postgres database loaded with sample data, dbt, and query tools.

1. Go to https://codespaces.new/datamindedacademy/academy_dbt
2. Click **Create codespace** (don't change any settings).
3. Wait a few minutes while the environment builds.

That's it. No local installation, no accounts to create, no credentials to manage.
See [`sql/README.md`](sql/README.md) for how to run your first query.

## The dataset

All exercises use the **TPC-H** dataset: a fictional wholesale business with
customers, orders, parts, and suppliers. It is the "hello world" of relational
databases. The tables live in the `tpch` schema of the Postgres database.
The schema is explained in [`sql/README.md`](sql/README.md).

> **Note:** the sample data in this environment is small (150 customers,
> 1500 orders). If a query unexpectedly returns zero rows, your logic may still be
> correct — try relaxing a threshold to check.

## Solutions

Solution branches exist for several dbt exercises (e.g. `solutions/exercise_1`,
`solutions/exercise_2`, `solutions/vars`, `solutions/for_loops`, `solutions/macros`,
`solutions/exercise_testing`). Try the exercise yourself first — the struggle is
where the learning happens.
