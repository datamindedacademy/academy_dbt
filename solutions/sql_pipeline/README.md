# Run the SQL pipeline in a SQL editor

This is one SQL script with a fixed statement order.
It builds the same eight data-product objects as [the dbt project](../dbt/dataproducts/).
Your Databricks browser session provides the connection. This SQL workflow needs no token or dbt profile.

## Run it

1. Open the Databricks **SQL editor** and create a query.
2. Select your SQL warehouse.
3. Copy [run_pipeline.sql](run_pipeline.sql) into the editor.
4. Run sections 1–3 in order. Check that all 17 failure counts are zero.
5. Run sections 4–6. Check the nine consumer checks and the SQL comparison.
6. Run section 7 to see the report and its totals.

Highlight a section and select **Run** to execute that section.
You can also select **Run all statements** to repeat the complete script.
The check queries return counts. They do not stop later statements when a count exceeds zero.
With section-by-section execution, stop manually when a check fails.
See the [Databricks SQL editor instructions](https://docs.databricks.com/aws/en/sql/user/sql-editor/run-queries).

The script reads `samples.tpch` and writes to `workspace.dbt_sql_dataproducts`.
It replaces its eight views and tables each time.
The default period is January through March 1995. The end date, `1995-04-01`, is exclusive.
To use another period, change both date literals throughout the script.

## Compare with dbt

Run the dbt data-product project with the same dates and destination catalog.
Then run [compare_dbt.sql](compare_dbt.sql) in the SQL editor.
The expected result is `dbt_equivalence` with `failures = 0`.
It compares every output column and duplicate row count.
If your dbt profile uses another catalog or schema, update the table paths in the comparison.

## Demonstrate a failure

Run [demo_duplicate_customer.sql](demo_duplicate_customer.sql) once after a successful SQL run.
The customer uniqueness check returns `failures = 1`.
Stop before you rebuild the consumer product. SQL leaves that decision to you in this example.
Rerun the normal script to restore the data and inspect all checks again.
A previous report can remain after a failed check. The statements do not form one transaction.

See the [instructor guide](../../docs/run_both_pipelines.md) for both workflows and the dbt comparison.
