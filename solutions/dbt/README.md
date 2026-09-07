# dbt exercise solutions

The answers follow dbt exercises 1–11 on `main` and the Databricks slides.
Use `dbt_academy` as the project name. The deck still uses its previous name, `dbt_test`.

Run the completed models from [exercises/](exercises/).
The numbered SQL files contain plain SQL equivalents and commented dbt examples.
Select one plain SQL query at a time in the Databricks SQL editor.
The separate [data-product demo](dataproducts/) follows exercise 11.

## 1. Create the project

From the repository root, follow the [setup guide](../../docs/setup_instructions.md).
`dbt init dbt_academy --skip-profile-setup` creates the starter project.
After `dbt run`, the first model has `1` and `NULL`. The second model has only `1`.
The completed solution already includes the null fix from exercise 5.

## 2. Declare sources and build models

See [the SQL answer](02_sources_and_staging.sql) and [the source declaration](exercises/models/sources.yml).
Use a left join to retain customers without orders. Their `total_spent` is NULL.
The completed [customer_stats](exercises/models/customer_stats.sql) also includes the loop from exercise 8.

## 3. Choose tables or views

`customer_stats` starts as a view because dbt defaults to views.
The project setting changes it to a table:

```yaml
models:
  dbt_academy:
    +materialized: table
```

The model setting `{{ config(materialized='view') }}` changes it back to a view.
The completed project contains both settings to show that the model setting takes precedence.

## 4. Explore documentation

From the repository root:

```bash
dbt docs generate --project-dir solutions/dbt/exercises
dbt docs serve --project-dir solutions/dbt/exercises --port 8080
```

Open port **8080** in Codespaces.
Trace `tpch.customer → stg_customer → customer_stats` and `tpch.orders → stg_orders → customer_stats`.
See [model and column descriptions](exercises/models/customer_stats.yml).

## 5. Detect invalid output

The starter `not_null` test fails because the first model contains NULL.
The fix is `select 1 as id` in [my_first_dbt_model.sql](exercises/models/example/my_first_dbt_model.sql).
Run `dbt build` after the edit to replace the data before the tests run.

[customer_stats.yml](exercises/models/customer_stats.yml) tests `c_custkey` with `unique` and `not_null`.
[customer_stats_nonnegative.sql](exercises/tests/customer_stats_nonnegative.sql) selects negative totals.
A SQL test passes when it returns zero rows. See the [plain SQL answer](05_testing.sql).

## 6. Select models from the example graph

These commands answer the slide's graph exercise. The example graph is separate from the TPC-H project.

1. Run `session` and its descendants, except `agg_per_user`:

   ```bash
   dbt run --select session+ --exclude agg_per_user
   ```

2. Intersect descendants of `session` with ancestors of `agg_per_program`:

   ```bash
   dbt run --select session+,+agg_per_program
   ```

3. Select models affected by the source change:

   ```bash
   dbt run --select source:app.schedule+
   ```

4. Add `{{ config(tags=['daily']) }}` to `agg_per_program` and `agg_per_user`.
   Add `{{ config(tags=['monthly']) }}` to `least_popular_program`.
   Run daily models with their upstream models, then run the monthly model after the daily run:

   ```bash
   dbt run --select +tag:daily
   dbt run --select tag:monthly
   ```

## 7. Filter with date variables

See [the variables and SQL answer](07_jinja_variables.sql).
Both dates are inclusive: `1995-01-01` through `1995-03-31`.
[orders_date_in_range.sql](exercises/tests/orders_date_in_range.sql) returns rows outside those dates.
The completed [orders model](exercises/models/orders.sql) uses the equivalent macro from exercise 9.

## 8. Generate status counts

See [the loop and plain SQL answer](08_jinja_for_loops.sql).
Count O, P, and F into `num_orders_with_status_o`, `num_orders_with_status_p`, and `num_orders_with_status_f`.
Customers without orders have zero in all three columns.
The [completed model](exercises/models/customer_stats.sql) uses a loop and the `order_statuses` project variable.

## 9. Reuse the date filter

[is_in_reporting_interval](exercises/macros/is_in_reporting_interval.sql) accepts a column and returns the inclusive date condition.
[orders.sql](exercises/models/orders.sql) calls it with `o_orderdate`.
See the [plain SQL answer](09_macros.sql).

For the optional package task, create `packages.yml`:

```yaml
packages:
  - package: dbt-labs/dbt_utils
    version: 1.3.0
```

Run `dbt deps`, then build `stg_orders` before the macro reads its values.
Replace the status list in the loop with:

```jinja
{% set statuses = dbt_utils.get_column_values(ref('stg_orders'), 'o_orderstatus') %}
{% for status in statuses %}
```

The completed project uses the project variable and needs no package download.

## 10. Upload a seed and record history

The [CSV](exercises/seeds/country_codes.csv) starts with US, CA, GB, BE, and NL.
The [snapshot](exercises/snapshots/country_codes_snapshot.yml) uses `country_code`, strategy `check`, and `check_cols: all`.
Run from the repository root:

```bash
dbt seed --project-dir solutions/dbt/exercises
dbt snapshot --project-dir solutions/dbt/exercises
```

Add `CN,China` to the CSV. Run both commands again.
Then add a `continent` column and fill every row.
`dbt seed` fails because the existing table has only two columns. Run:

```bash
dbt seed --full-refresh --project-dir solutions/dbt/exercises
dbt snapshot --project-dir solutions/dbt/exercises
```

For a fresh snapshot, the expected counts are:

| State | Seed rows | Current versions | Historical versions | Total snapshot rows |
|---|---:|---:|---:|---:|
| Initial five countries | 5 | 5 | 0 | 5 |
| China added | 6 | 6 | 0 | 6 |
| Continent added to all rows | 6 | 6 | 6 | 12 |

Current versions have `dbt_valid_to IS NULL`.

## 11. Build the country report

[stg_nation](exercises/models/stg_nation.sql) reads the nation source.
[int_orders_with_nation](exercises/models/int_orders_with_nation.sql) joins the three staging models and applies the date macro.
[revenue_per_nation](exercises/models/revenue_per_nation.sql) returns `nation_key`, `nation`, `customers`, `orders`, and `revenue`.
It uses the customer's nation and full order value across all statuses.

The [YAML tests](exercises/models/revenue_per_nation.yml) check unique, non-null nation keys.
The [SQL test](exercises/tests/revenue_per_nation_nonnegative.sql) detects negative revenue.
See [the equivalent SQL](11_country_report.sql).
After `dbt build`, run the comparison:

```bash
dbt show --project-dir solutions/dbt/exercises --select compare_country_report
```

Zero rows means both reports match, including duplicate counts.
