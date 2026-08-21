# Exercise 3 — Materializations

## Goal

Control whether a model becomes a **view** or a **table**, and understand which
configuration wins when two settings conflict.

## Why this matters

The same `SELECT` can be materialized in different ways, with a real
cost/performance trade-off. Choosing per model — with one line of config,
without touching the SQL — is a core dbt skill.

## Concepts

A **table** is a physical object: the query result is computed once, at
`dbt run` time, and stored (write slow, read fast). A **view** stores only the
query itself; the database re-executes it every time someone reads from the view
(write fast, read slow).

dbt supports four materializations. The default is `view`:

- `view` (default), `table`
- `incremental`, `ephemeral` (covered in the capstone-level material)

There are 2 ways to configure it, and A "trumps" B:

**A) In the model itself** (top of the `.sql` file):

```sql
{{ config(materialized='view') }}
```

**B) In `dbt_project.yml`** (applies to a whole folder of models):

```yaml
models:
  dbt_test:
    example:
      +materialized: table
```

## Exercise

In the dbt project you created:

1. Run `dbt run`. Is `customer_stats` a view or a table in the database? Why?
2. Change the default materialization of all models to `table` in
   `dbt_project.yml`.
3. Run `dbt run`. Is `customer_stats` a view or a table now? Why?
4. Keep the changes in `dbt_project.yml`. Add
   `{{ config(materialized='view') }}` to the model `customer_stats`.
5. Run `dbt run`. Is `customer_stats` a view or a table now? Why?

## Tips

- In pgAdmin, tables and views appear in separate groups under the schema
  (refresh after each run). In SQLTools, expand the schema tree.
- To see what dbt actually executed, look in `target/run/` — the compiled SQL
  including the generated `CREATE VIEW` / `CREATE TABLE` statements.
