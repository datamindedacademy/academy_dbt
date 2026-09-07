# dbt exercise 3: Choose tables or views

Change how dbt stores a model and compare the results.

1. Run `dbt run`. Inspect the type of `customer_stats` in Databricks.
2. Set the project default in `dbt_project.yml`:

   ```yaml
   models:
     dbt_academy:
       +materialized: table
   ```

3. Run `dbt run`. Inspect the model type again.
4. Add this line at the top of `models/customer_stats.sql`:

   ```sql
   {{ config(materialized='view') }}
   ```

5. Run `dbt run`. Inspect the model type again. Which configuration takes precedence?

A table stores the query result. A view stores the query.
Model configuration overrides the project default.
