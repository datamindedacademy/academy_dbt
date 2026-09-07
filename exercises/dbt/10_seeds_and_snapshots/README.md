# dbt exercise 10: Upload a seed and record its history

Upload a CSV with `dbt seed`. Record changed versions with `dbt snapshot`.

1. Create `seeds/country_codes.csv`:

   ```csv
   country_code,country_name
   US,United States
   CA,Canada
   GB,United Kingdom
   BE,Belgium
   NL,The Netherlands
   ```

2. Create `snapshots/country_codes_snapshot.yml`:

   ```yaml
   snapshots:
     - name: country_codes_snapshot
       relation: ref('country_codes')
       config:
         unique_key: country_code
         strategy: check
         check_cols: all
   ```

3. Run `dbt seed` and `dbt snapshot`. Inspect both tables in `workspace.dbt`.
4. Add `CN,China` to the CSV. Run both commands again. Count the snapshot rows.
5. Add a `continent` column and fill every row. Run `dbt seed`. Inspect the error.
6. Run `dbt seed --full-refresh`, then `dbt snapshot`. Inspect the new versions.

The `check` strategy compares column values because this seed has no update timestamp.
`dbt_valid_from` marks a version's start. `dbt_valid_to` is NULL for the current version.
