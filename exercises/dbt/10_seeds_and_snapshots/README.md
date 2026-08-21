# Exercise 10 — Seeds and snapshots

## Goal

Load a small CSV file into the warehouse with `dbt seed`, and track its history
over time with `dbt snapshot`.

## Why this matters

- **Seeds** solve the "where do I put this small lookup table?" problem: version
  the CSV with your code, and dbt loads it.
- **Snapshots** solve the "the source table only shows the current state, but I
  need the history" problem — one of the most common requests in analytics.

## Concepts

**Seeds** are CSV files in the `seeds/` folder. `dbt seed` uploads them as
tables; downstream models use them via `ref()` like any model.

- ✅ Use for: small, static mapping tables (country codes, category names).
- ❌ Don't use for: raw data, big tables, or sensitive data (seeds live in git!).

Two pitfalls:

- A column name that is a reserved SQL keyword (like `order`) fails, because dbt
  doesn't quote seed columns by default. Fix in `dbt_project.yml`:
  `seeds: +quote_columns: true`.
- Changing the *columns* of a seed makes `dbt seed` fail, because dbt truncates
  and re-inserts instead of dropping (to protect downstream objects). Fix:
  `dbt seed --full-refresh`.

**Snapshots** capture how a table changes over time (a "type-2 slowly changing
dimension"). Each run of `dbt snapshot` compares the current data with the last
recorded version. dbt adds two columns to every row:

- `dbt_valid_from` — when this version of the row appeared
- `dbt_valid_to` — when it was replaced (`NULL` = still valid)

A snapshot is a `.yml`/`.sql` definition in the `snapshots/` folder, with a
*strategy* for detecting changes: `timestamp` (recommended; uses an
`updated_at` column) or `check` (compares a list of columns — for tables
without a reliable timestamp).

## Exercise

1. Add this seed as `seeds/country_codes.csv`:

   ```csv
   country_code,country_name
   US,United States
   CA,Canada
   GB,United Kingdom
   BE,Belgium
   NL,The Netherlands
   ```

2. Create a snapshot that reads the seed. Which strategy should you use? Why?
3. Run `dbt seed` and `dbt snapshot`. Look at the snapshot table in the
   database.
4. Add a row to the CSV: China.
5. Run `dbt seed` and `dbt snapshot` — how many rows did the snapshot add?
6. Add a column to the CSV: `continent` (fill it in for each country).
7. Run `dbt seed` and `dbt snapshot` — how many rows did it add? What happened?

## Tips

- The seed has no `updated_at` column — that answers question 2.
- Remember the second pitfall when you reach step 7.
- Snapshot reference: https://docs.getdbt.com/docs/build/snapshots
