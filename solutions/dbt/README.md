# dbt exercise solutions

The answers follow dbt exercises 1–11 on `main` and the Databricks slides.
Use `dbt_academy` as the project name. The deck still uses its previous name, `dbt_test`.

Run every command below from the repository root in the Codespace terminal.
Exercise 1 creates your starter project. Exercises 2–11 use the supplied [completed project](exercises/), except the example graph.
For your own models, replace `--project-dir solutions/dbt/exercises` with `--project-dir dbt_academy`.
The numbered `.sql` snippets are examples; the commands run models from the selected dbt project.

Before you use the completed project, generate its profile:

```bash
./create_profiles.sh --target databricks
```
The numbered SQL files contain plain SQL equivalents and commented dbt examples.
Select one plain SQL query at a time in the Databricks SQL editor.
The separate [data-product demo](dataproducts/) follows exercise 11.

## 1. Create the project

From the repository root, follow the [setup guide](../../docs/setup_instructions.md).
Run these commands. Skip `dbt init` if `dbt_academy` already exists.

```bash
dbt init dbt_academy --skip-profile-setup
./create_profiles.sh --target databricks
dbt debug --project-dir dbt_academy
dbt run --project-dir dbt_academy
dbt show --project-dir dbt_academy --select my_first_dbt_model
dbt show --project-dir dbt_academy --select my_second_dbt_model
```
After `dbt run`, the first model has `1` and `NULL`. The second model has only `1`.
The completed solution already includes the null fix from exercise 5.

## 2. Declare sources and build models

See [the SQL answer](02_sources_and_staging.sql) and [the source declaration](exercises/models/sources.yml).
Use a left join to retain customers without orders. Their `total_spent` is NULL.
The completed [customer_stats](exercises/models/customer_stats.sql) also includes the loop from exercise 8.

Run the staging models and customer report, then inspect the output:

```bash
dbt run --project-dir solutions/dbt/exercises --select +customer_stats
dbt show --project-dir solutions/dbt/exercises --select customer_stats --limit 10
```

The `+` includes the upstream models, so this also works before their first build.

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
Run this command after each configuration change:

```bash
dbt run --project-dir solutions/dbt/exercises --select +customer_stats
```

Inspect `workspace.dbt.customer_stats` in Databricks after each run.
In the completed project, remove the model's `config()` line to see the project default create a table.
Restore that line and repeat the command to create a view again.

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
To see the failure in the starter project from exercise 1, run:

```bash
dbt test --project-dir dbt_academy
```

The completed solution already contains the fix. Build it and run its relevant tests:

```bash
dbt build --project-dir solutions/dbt/exercises --select +customer_stats my_first_dbt_model my_second_dbt_model
dbt test --project-dir solutions/dbt/exercises --select customer_stats my_first_dbt_model my_second_dbt_model
```

If you fix your own starter model, run `dbt build --project-dir dbt_academy` to refresh its data and tests.

[customer_stats.yml](exercises/models/customer_stats.yml) tests `c_custkey` with `unique` and `not_null`.
[customer_stats_nonnegative.sql](exercises/tests/customer_stats_nonnegative.sql) selects negative totals.
A SQL test passes when it returns zero rows. See the [plain SQL answer](05_testing.sql).

## 6. Select models from the example graph

These commands answer the slide's graph exercise. The example graph is separate from the TPC-H project.
Run them from a project's folder only if it contains those example models. They are not runnable in the supplied project.

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

```bash
dbt run --project-dir solutions/dbt/exercises --select +orders
dbt test --project-dir solutions/dbt/exercises --select orders
dbt show --project-dir solutions/dbt/exercises --select orders --limit 10
```

Open `solutions/dbt/exercises/target/compiled/dbt_academy/models/orders.sql` to see the rendered dates.

## 8. Generate status counts

See [the loop and plain SQL answer](08_jinja_for_loops.sql).
Count O, P, and F into `num_orders_with_status_o`, `num_orders_with_status_p`, and `num_orders_with_status_f`.
Customers without orders have zero in all three columns.
The [completed model](exercises/models/customer_stats.sql) uses a loop and the `order_statuses` project variable.

```bash
dbt run --project-dir solutions/dbt/exercises --select +customer_stats
dbt show --project-dir solutions/dbt/exercises --select customer_stats --limit 10
```

Open `solutions/dbt/exercises/target/compiled/dbt_academy/models/customer_stats.sql` to see the three generated expressions.

## 9. Reuse the date filter

[is_in_reporting_interval](exercises/macros/is_in_reporting_interval.sql) accepts a column and returns the inclusive date condition.
[orders.sql](exercises/models/orders.sql) calls it with `o_orderdate`.
See the [plain SQL answer](09_macros.sql).

```bash
dbt run --project-dir solutions/dbt/exercises --select +orders
dbt test --project-dir solutions/dbt/exercises --select orders
dbt show --project-dir solutions/dbt/exercises --select orders --limit 10
```

Inspect `solutions/dbt/exercises/target/compiled/dbt_academy/models/orders.sql` for the expanded macro.

For the optional package task, create `packages.yml`:

```yaml
packages:
  - package: dbt-labs/dbt_utils
    version: 1.3.0
```

Save the optional package file as `solutions/dbt/exercises/packages.yml`.
Install the package and build `stg_orders` before the macro reads its values:

```bash
dbt deps --project-dir solutions/dbt/exercises
dbt run --project-dir solutions/dbt/exercises --select stg_orders
```
Replace the status list in the loop with:

```jinja
{% set statuses = dbt_utils.get_column_values(ref('stg_orders'), 'o_orderstatus') %}
{% for status in statuses %}
```

After the loop edit, run:

```bash
dbt run --project-dir solutions/dbt/exercises --select +customer_stats
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

Add `CN,China` to the CSV. Run:

```bash
dbt seed --project-dir solutions/dbt/exercises
dbt snapshot --project-dir solutions/dbt/exercises
```
Then add a `continent` column and fill every row.
First run this command to see the column mismatch error:

```bash
dbt seed --project-dir solutions/dbt/exercises
```

The existing table has only two columns. Recreate it, then update the snapshot:

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
Build the models and their dependencies, inspect the output, compare with SQL, and generate the documentation:

```bash
dbt build --project-dir solutions/dbt/exercises --select +revenue_per_nation
dbt show --project-dir solutions/dbt/exercises --select revenue_per_nation --limit 10
dbt show --project-dir solutions/dbt/exercises --select compare_country_report
dbt docs generate --project-dir solutions/dbt/exercises
```

Zero rows means both reports match, including duplicate counts.
