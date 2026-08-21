# Exercise 5 — Testing your data

## Goal

Run dbt's built-in tests, fix a failing one, and write both a generic and a
singular test for your own model.

## Why this matters

Data silently goes wrong: duplicates appear, keys go missing, an upstream export
changes. Tests turn your assumptions ("this column is unique") into checks that
run in seconds with `dbt test` — in development while you write code, and on a
schedule in production. Catching problems early is far cheaper than debugging a
wrong report.

## Concepts

dbt has two types of tests:

**Generic tests** are predefined checks you attach to a column in a `.yml` file.
dbt ships with four:

- `unique` — every value in the column is unique
- `not_null` — no value in the column is NULL
- `accepted_values` — every value is in a given list
- `relationships` — every value exists in a column of another model
  (referential integrity)

```yaml
models:
  - name: model1
    columns:
      - name: unique_id
        data_tests:
          - unique
          - not_null
      - name: status
        data_tests:
          - accepted_values:
              values: ['placed', 'shipped', 'completed']
```

**Singular tests** are `.sql` files in the `tests/` folder. The idea: write a
query that selects the *wrong* rows. Zero rows returned = test passed; any row
returned = test failed.

```sql
-- tests/no_negative_spending.sql
SELECT * FROM {{ ref('customer_stats') }}
WHERE total_spent < 0
```

> Watch out: filtering an *empty* table also gives zero rows, so an empty model
> passes every singular test of this shape. Use `count(*)` + `HAVING` if you
> also want to assert the table is not empty.

Run all tests with `dbt test`.

## Exercise

In the dbt project you created:

1. Look into the generic tests in `models/schema.yml` (dbt's example project
   ships with some). What do they do?
2. Run `dbt test`. Is it successful? Why? Can you fix it?
3. For the model `customer_stats` added in exercise 2:
   - Add it to `schema.yml`.
   - Add one or more **generic** tests (your choice).
   - Add one or more **singular** tests (your choice).

## Tips

- When a test fails, dbt prints the compiled query it ran — execute it yourself
  to see the offending rows.
- Ideas for `customer_stats`: `custkey` should be `unique` and `not_null`; the
  total spent should never be negative.
- Solution branch: `solutions/exercise_testing`.
