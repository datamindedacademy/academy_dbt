# dbt solutions — non-SQL answers

The `.sql` files in this folder cover the dbt exercises whose solution is SQL.
The other exercises are answered here: their solutions are commands, YAML, or
observations.

## Exercise 1 — Your first dbt project

- `dbt debug` succeeds when the connection details are correct.
- Before `dbt run`: the schema contains only the raw TPC-H tables.
- After `dbt run`: two new objects appear.
- `my_first_dbt_model` builds a **table** with 2 rows (`id` = 1 and NULL);
  it has `{{ config(materialized='table') }}` at the top.
- `my_second_dbt_model` builds a **view** that selects the row with `id = 1`
  from the first model, via `{{ ref('my_first_dbt_model') }}`.

## Exercise 3 — Materializations

1. `customer_stats` is a **view**: `view` is dbt's default materialization.
2. After `+materialized: table` in `dbt_project.yml`: it is a **table** —
   the project config now applies to all models in the folder.
3. After adding `{{ config(materialized='view') }}` in the model: it is a
   **view** again — config in the model itself "trumps" `dbt_project.yml`.

## Exercise 4 — Documentation

- `dbt docs generate` then `dbt docs serve`; open the forwarded port (8080).
- The lineage graph of `customer_stats` shows:
  source `tpch.customer`/`tpch.orders` (green) → `stg_customer`/`stg_orders`
  → `customer_stats`.

## Exercise 6 — Running specific models

1. `session` and everything downstream, except `agg_per_user`:
   ```bash
   dbt run --select session+ --exclude agg_per_user
   ```
2. `session` and its descendants that are also ancestors of `agg_per_program`
   (intersection = comma, no space):
   ```bash
   dbt run --select session+,+agg_per_program
   ```
3. Everything that depends on the `schedule` source table:
   ```bash
   dbt run --select source:my_source.schedule+
   ```
4. Tag `agg_per_program` and `agg_per_user` with `daily`, and
   `least_popular_program` with `monthly`. Then:
   - daily: `dbt run --select tag:daily`
   - monthly (after the daily run): `dbt run --select tag:monthly`

   Tags keep the schedule definition in one place: moving a model between the
   daily and monthly runs is a one-line change.

## Exercise 10 — Seeds and snapshots

- Strategy: **check** — the seed has no `updated_at` column, so the
  `timestamp` strategy cannot work. Compare all columns:
  `check_cols: all`.
- After the first `dbt snapshot`: 5 rows, all with `dbt_valid_to = NULL`.
- After adding China: `dbt seed` + `dbt snapshot` adds **1** row.
- After adding the `continent` column: `dbt seed` **fails** (dbt truncates and
  re-inserts; the column list no longer matches). Fix:
  `dbt seed --full-refresh`. The next `dbt snapshot` then sees every row as
  changed (a new column value in each), so it invalidates all 6 old rows and
  inserts **6** new ones.

## Exercise 11 — Capstone

The capstone is a full dbt project, not a single file. Model split, following
the staging / intermediate / marts layering:

- `1_staging/`: `stg_cases_muni`, `stg_vacc_muni_cum`, `stg_population`
  (thin `SELECT`s over the sources)
- `2_intermediate/`: `int_vaccinations_per_municipality`,
  `int_cases_per_municipality` (the logic of views 1 and 2)
- `3_marts/`: `covid_stats_per_municipality` (view 3: the joins and the
  per-capita columns)

The covid dataset is not in the Databricks `samples` catalog; upload it first
(see the note in the capstone exercise).
