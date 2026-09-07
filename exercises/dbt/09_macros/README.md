# dbt exercise 9: Reuse the date filter in a macro

Replace the filter from exercise 7 with a reusable macro.

1. Create `macros/is_in_reporting_interval.sql`.
2. Define `is_in_reporting_interval(date_column)`. Return a condition between the two report variables.
3. Replace the filter in `models/orders.sql` with:

   ```sql
   where {{ is_in_reporting_interval('o_orderdate') }}
   ```

4. Run `dbt run` and `dbt test`. Inspect the compiled SQL and the order dates.

Define the macro with `{% macro is_in_reporting_interval(date_column) %}` and `{% endmacro %}`.
Keep the SQL dates quoted, as in exercise 7.

Optional: add `dbt-labs/dbt_utils` version `1.3.0` to `packages.yml` and run `dbt deps`.
Use `dbt_utils.get_column_values()` to obtain the order statuses for exercise 8.
Build the referenced model before this macro queries it.
