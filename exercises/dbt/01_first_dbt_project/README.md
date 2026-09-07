# dbt exercise 1: Create your first project

Create a project and run its example models on Databricks.

1. Run these commands from the repository root. Skip `dbt init` if `dbt_academy` already exists.

   ```bash
   dbt init dbt_academy --skip-profile-setup
   ./create_profiles.sh --target databricks
   cd dbt_academy
   dbt debug
   dbt run
   ```

2. Confirm that `dbt debug` reports `All checks passed!`.
3. Open **Catalog > workspace > dbt** in Databricks. Refresh the schema.
4. Inspect `my_first_dbt_model` and `my_second_dbt_model`. Compare their rows with the SQL in `models/example/`.
5. Find `dbt_project.yml`. Check its profile name and the model paths.

The first example contains `1` and `NULL`. The second contains only `1`.
The starter project has a deliberate failing test. Exercise 5 fixes it.

The profile script reads your private `.env` and writes `~/.dbt/profiles.yml`.
Rerun it after you create a project or replace a token.
