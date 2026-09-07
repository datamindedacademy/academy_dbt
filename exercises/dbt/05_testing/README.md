# dbt exercise 5: Detect invalid model output

Fix the starter test and add tests for `customer_stats`.

1. Inspect `models/example/schema.yml`. Run `dbt test` and identify the failing test.
2. Fix the NULL in `my_first_dbt_model.sql`. Run `dbt build` to rebuild the models and run their tests.
3. Extend the existing `customer_stats` entry in `models/customer_stats.yml`:

   ```yaml
   columns:
     - name: c_custkey
       data_tests: [unique, not_null]
   ```

4. Add `tests/customer_stats_nonnegative.sql`:

   ```sql
   select c_custkey, total_spent
   from {{ ref('customer_stats') }}
   where total_spent < 0
   ```

5. Run `dbt test`. Inspect each result.

The YAML checks are generic data tests. A SQL test passes when its query returns zero rows.
`dbt test` checks existing data. Use `dbt build` after a model edit to refresh the data first.
