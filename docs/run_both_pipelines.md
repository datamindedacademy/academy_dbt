# Instructor guide: compare the SQL and dbt pipelines

The SQL pipeline produces the same report as dbt.
The demonstration shows who manages the build order, checks, and documentation.
dbt also sends SQL to Databricks.

## The message for the class

| Approach | What works well | What you must manage |
|---|---|---|
| This SQL script | One database connection. Visible SQL statements. Easy to inspect each result. | Statement order, check results, and the decision to stop after a failure. |
| This dbt project | Dependencies, attached tests, and generated documentation. | A dbt installation, connection profile, model configuration, and Jinja expressions. |

SQL is sufficient for this report. Both versions use SQL for the calculations.
dbt reduces the manual work around the calculations as models and dependencies increase.
SQL can also automate checks through database scripts or jobs. This example deliberately uses a manual SQL workflow.

## Prepare the demonstration

1. Use branch `feature/self-service-solutions`. Run `git pull --ff-only`.
2. Open your Databricks SQL editor and select your SQL warehouse.
3. Complete [the connection setup](setup_instructions.md) for dbt.
4. Run these commands from the repository root in the Codespace terminal:

   ```bash
   ./create_profiles.sh --target databricks
   dbt debug --project-dir solutions/dbt/dataproducts
   ```

Use `solutions/dbt/dataproducts` for this demonstration.
It uses the `academy_dataproducts` profile. The exercise answers under `solutions/dbt/exercises` are a separate project.

## 1. Show a successful SQL run

Copy [run_pipeline.sql](../solutions/sql_pipeline/run_pipeline.sql) into the Databricks SQL editor.
Highlight and run each numbered section in order.

| Section | Action | Passing result |
|---|---|---|
| 1–2 | Create the source product | Six objects: three views and three tables |
| 3 | Check the source product | 17 result rows, all with `failures = 0` |
| 4 | Create the consumer product | Two objects: one view and one table |
| 5 | Check the consumer product | Nine result rows, all with `failures = 0` |
| 6 | Compare with the original SQL | One result row with `failures = 0` |
| 7 | Show the report | Ten preview rows and the totals below |

Expected totals for the course sample data:

| report_rows | orders | order_value |
|---:|---:|---:|
| 75 | 280,721 | 42,417,781,915.94 |

The report covers January through March 1995, across all order statuses.
It uses the customer's country. The sample specifies no currency.

**How to read a SQL check:**

| Result | Meaning | Your action |
|---|---|---|
| `failures = 0` | This check finds no invalid rows or groups | Continue if every check passes |
| `failures > 0` | This check finds a data problem | Stop before the next build section |
| SQL error | The statement does not complete | Fix the error before you continue |

A query can execute successfully and return `failures = 1`.
The editor's success indicator confirms execution. The failure count tells you whether the data passes the check.

Say: “SQL builds the complete report. I inspect the checks and decide whether to continue.”

You can use **Run all statements** for a complete rerun.
A positive failure count does not stop that rerun automatically.
See [the SQL editor controls](https://docs.databricks.com/aws/en/sql/user/sql-editor/run-queries).

## 2. Show a successful dbt run

In the Codespace terminal:

```bash
dbt build --project-dir solutions/dbt/dataproducts
dbt show --project-dir solutions/dbt/dataproducts --select preview_monthly_order_value --limit 10
```

Show eight completed models, 27 passing data tests, and one passing unit test.
The unit test checks small example inputs. Four published models also have column and type contracts.

Say: “dbt builds the dependencies and runs their attached tests with one command.”

## 3. Prove that both reports match

Run [compare_dbt.sql](../solutions/sql_pipeline/compare_dbt.sql) in the Databricks SQL editor.

| check_name | Passing value | Failing value |
|---|---|---|
| `dbt_equivalence` | `failures = 0` | `failures > 0` |

The query compares all columns and duplicate row counts in both directions.
A zero result confirms that both reports contain the same rows.
If it fails, check that both builds finish successfully and use the same dates.

The default report tables are:

- SQL: `workspace.dbt_sql_dataproducts.ca_sales_ext_monthly_order_value`
- dbt: `workspace.dbt_dataproducts.ca_sales_ext_monthly_order_value`

The SQL paths assume catalog `workspace` and base schema `dbt` in `.env`.
Update the SQL paths if your profile uses different values.

## 4. Show the difference when data fails a check

### SQL: you must stop

1. Run [demo_duplicate_customer.sql](../solutions/sql_pipeline/demo_duplicate_customer.sql) once after the successful SQL build.
2. Show `customers_customer_id_unique` with `failures = 1`.
3. Explain that one customer identifier now occurs more than once.
4. Stop before the consumer build. Its join would count that customer's orders twice.
5. Rerun `run_pipeline.sql` from section 1. Confirm that all 27 checks return zero again.

The failure is intentional. A check that reports `1` correctly detects the problem.
The weakness of this manual workflow is that the operator must notice it and stop.

### dbt: the failed test blocks dependent models

Run in the Codespace terminal:

```bash
dbt build --project-dir solutions/dbt/dataproducts --vars '{inject_duplicate_customer: true}'
```

Show the failed customer uniqueness test and the two skipped consumer models.
This failure is intentional too. dbt stops those dependent builds without a manual decision.

Restore the normal data:

```bash
dbt build --project-dir solutions/dbt/dataproducts
```

Run `compare_dbt.sql` again. Expect `failures = 0`.
Both workflows can leave an earlier report after a failure. Neither build rolls back every table as one transaction.

## 5. Show the documentation

Run in the Codespace terminal:

```bash
dbt docs generate --project-dir solutions/dbt/dataproducts
dbt docs serve --project-dir solutions/dbt/dataproducts --port 8080
```

Open port **8080** in Codespaces.
Trace the reusable source tables into the consumer report. Open a model's descriptions, tests, and column types.

Say: “With this SQL script, I maintain the build order and explanations myself.”
Say: “dbt builds the dependency graph and documentation from the project definitions.”
