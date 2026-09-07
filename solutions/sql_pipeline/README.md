# SQL pipeline for the TPC-H data products

This pipeline builds the same eight objects as [the dbt project](../dbt/dataproducts/).
It uses SQL files and a Python runner. It does not invoke dbt.

Complete [Databricks setup](../../docs/setup_instructions.md#databricks-free-edition), then run these commands from the repository root:

```bash
./create_profiles.sh --target databricks
python solutions/sql_pipeline/run.py
dbt build --project-dir solutions/dbt/dataproducts
python solutions/sql_pipeline/run.py --compare-only
```

## Execution order

`run.py` contains the explicit `STEPS` list:

1. Create three internal source views.
2. Create three published source tables.
3. Run 17 source checks. Stop if any check fails.
4. Create the internal consumer view and published report table.
5. Run ten consumer checks, including the independent SQL comparison.
6. Display the first ten rows and the report totals.

Each SQL file contains a complete statement, including `CREATE OR REPLACE` for each model.
The runner fills `${destination}`, the date values, and the optional duplicate flag.
These placeholders belong to the runner. A SQL editor cannot substitute them automatically.
To run a file directly, replace its placeholders with the required values first.

The runner reads the `academy_dataproducts` profile from `~/.dbt/profiles.yml`.
It uses the Databricks SQL Connector that the course adapter installs.
It uses the profile file only for credentials and connection settings.

The default destination is `workspace.dbt_sql_dataproducts`.
The dbt version uses `workspace.dbt_dataproducts`.
Both versions read `samples.tpch`.

## Failure and recovery

```bash
python solutions/sql_pipeline/run.py --inject-duplicate-customer
```

This command returns exit status 1.
The customer uniqueness check fails. The runner marks both consumer build steps as `SKIP`.
The runner stops all remaining steps. It does not calculate a dependency graph.

Restore the source product and the report:

```bash
python solutions/sql_pipeline/run.py
```

A previous report table can remain after a failed run.
The runner does not publish all tables in one transaction.

## Options

| Option | Purpose |
|---|---|
| `--start 1995-04-01 --end 1995-05-01` | Select another period. The end date is exclusive. |
| `--compare-only` | Compare both existing report tables, including extra or missing rows. |
| `--profile NAME` | Read another dbt profile's Databricks output. |
| `--profiles-dir PATH` | Read another profile directory. |
| `--report-json PATH` | Save the step statuses for inspection. |

Build both reports for the same period before comparison.
The comparison includes every output column and duplicate row counts.
It returns exit status 1 when the reports differ.

The 27 SQL data checks match the rules in the dbt data tests.
The dbt project also has a unit test and declared model contracts.
This SQL runner does not implement those features.
SQL can support them through more code or another orchestration tool.
