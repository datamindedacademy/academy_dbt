# Instructor guide: run the SQL and dbt data products

Use this demonstration after dbt exercise 11.
Both pipelines read `samples.tpch` and produce the same monthly country report.
The SQL version uses the Databricks SQL editor. The dbt version uses the Codespace terminal.

## Before the demonstration

1. Use branch `feature/self-service-solutions` and run `git pull --ff-only`.
2. Open your Databricks workspace and SQL warehouse.
3. Complete [the connection setup](setup_instructions.md) for dbt.
4. From the repository root in the Codespace terminal, run:

   ```bash
   ./create_profiles.sh --target databricks
   dbt debug --project-dir solutions/dbt/dataproducts
   ```

The profile script creates `academy_dataproducts` for this demo.
Use `solutions/dbt/dataproducts` for the data products. The completed exercise project is under `solutions/dbt/exercises`.

## 1. Run the SQL pipeline

1. Open [run_pipeline.sql](../solutions/sql_pipeline/run_pipeline.sql) in the repository.
2. Copy its contents into a new query in the Databricks **SQL editor**.
3. Select your SQL warehouse.
4. Highlight and run the numbered sections in order:

| Sections | What to show | Expected result |
|---|---|---|
| 1–2 | Create the schema and source product | Three internal views and three published tables |
| 3 | Check the source product | 17 rows; every `failures` value is `0` |
| 4 | Build the consumer product | One internal view and one published table |
| 5–6 | Check the consumer product and compare with the original SQL | Nine checks and one comparison; all failure counts are `0` |
| 7 | Inspect the report | Ten preview rows and one totals row |

Stop if a check returns a failure count above zero.
These checks are SELECT queries. They report problems but do not stop later statements automatically.
After the explanation, **Run all statements** repeats the complete pipeline.
See [the SQL editor controls](https://docs.databricks.com/aws/en/sql/user/sql-editor/run-queries).

Explain the two products:

- The source product publishes customers, nations, and orders for reuse.
- The consumer product joins those tables and calculates monthly order value per country.

The statement order comes from the SQL file. SQL references do not schedule the statements.
The script replaces its eight demo objects on each run.

## 2. Run the dbt pipeline

In the **Codespace terminal**, run from the repository root:

```bash
dbt build --project-dir solutions/dbt/dataproducts
```

Show the eight models, 27 data tests, and one unit test in the output.
The unit test uses small example inputs. Four published models also have contracts for their columns and types.

Show the result:

```bash
dbt show --project-dir solutions/dbt/dataproducts --select preview_monthly_order_value --limit 10
```

In Databricks, inspect these tables:

| Pipeline | Report table |
|---|---|
| SQL | `workspace.dbt_sql_dataproducts.ca_sales_ext_monthly_order_value` |
| dbt | `workspace.dbt_dataproducts.ca_sales_ext_monthly_order_value` |

These paths use the default `.env` settings: catalog `workspace` and base schema `dbt`.
If you change those settings, update the SQL paths too.
Both reports cover January through March 1995. The end date is exclusive: `1995-04-01`.
The country comes from the customer. All order statuses contribute to the report.

Expected totals on the course sample data:

| Report rows | Orders | Total order value |
|---:|---:|---:|
| 75 | 280,721 | 42,417,781,915.94 |

The sample data specifies no currency.

## 3. Compare the outputs

Copy [compare_dbt.sql](../solutions/sql_pipeline/compare_dbt.sql) into the **Databricks SQL editor** and run it.

Expected result:

| check_name | failures |
|---|---:|
| dbt_equivalence | 0 |

The comparison checks all columns and duplicate row counts in both directions.
Use the same dates in both pipelines before the comparison.

## 4. Show what happens when a check fails

### SQL

1. Run [demo_duplicate_customer.sql](../solutions/sql_pipeline/demo_duplicate_customer.sql) once in the SQL editor.
2. Show `customers_customer_id_unique` with `failures = 1`.
3. Stop before the consumer statements. Explain that you make this decision in the manual SQL workflow.
4. Rerun `run_pipeline.sql` from section 1 to restore the data. Inspect every check again.

### dbt

In the Codespace terminal, run:

```bash
dbt build --project-dir solutions/dbt/dataproducts --vars '{inject_duplicate_customer: true}'
```

Show the failed customer uniqueness test. Show that dbt skips both dependent consumer models.
Restore the normal data:

```bash
dbt build --project-dir solutions/dbt/dataproducts
```

Run `compare_dbt.sql` again. The failure count should return to zero.
Both workflows can leave an earlier report after a failure. Neither build rolls back every table as one transaction.

## 5. Show the dbt documentation

Run in the Codespace terminal:

```bash
dbt docs generate --project-dir solutions/dbt/dataproducts
dbt docs serve --project-dir solutions/dbt/dataproducts --port 8080
```

Open port **8080** in Codespaces.
Trace the published source tables into the consumer report. Open the descriptions, tests, and column types.

## What to explain

| Work | This manual SQL pipeline | dbt |
|---|---|---|
| Build order | You maintain the statement order | `ref()` defines dependencies |
| Create views and tables | You write the CREATE statements | Model settings choose views or tables |
| Check data | You run queries and inspect failure counts | `dbt build` runs the attached tests |
| Stop dependent work | You stop before later statements | Failed tests can block dependent models |
| Validate small examples | More SQL checks would be needed | The demo includes a unit test |
| Describe the products | Separate notes and SQL comments | Generated documentation and dependency graph |
| Change the date interval | Edit the date literals throughout the SQL file | Set the project variables |

SQL can also automate checks and execution through database scripts or jobs.
This demonstration starts with the manual workflow and shows which work dbt handles for you.
