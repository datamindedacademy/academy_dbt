# Solutions

These answers use the Databricks `samples.tpch` data and follow the exercises on `main`.

- [SQL answers](sql/): select one query at a time in the Databricks SQL editor.
- [dbt answers](dbt/README.md): commands, explanations, and links for exercises 1–11.
- [Completed dbt exercises](dbt/exercises/): run the exercise models with one `dbt build`.
- [Data-product demo](dbt/dataproducts/) and [SQL pipeline](sql_pipeline/): the separate demonstration after exercise 11.

Use the [Databricks setup guide](../docs/setup_instructions.md) for the connection.
The [instructor guide](../docs/run_both_pipelines.md) explains how to run and compare both pipelines.
The SQL pipeline runs directly in the Databricks SQL editor.

## Exercise and slide map

Slide numbers refer to the 171-slide Databricks edition of SQL & dbt Winterschool 2026.
The slides use the former project name `dbt_test`. The repository uses `dbt_academy`, as agreed for the course.
The exercise tasks are the same.

| Exercise | Slides | Answer |
|---|---|---|
| SQL 1: Select and filter | 20 | [SQL](sql/01_select_and_filter.sql) |
| SQL 2: Joins | 27 | [SQL](sql/02_joins.sql) |
| SQL 3: Aggregations | 32–33 | [SQL](sql/03_group_by_and_aggregations.sql) |
| SQL 4: CTEs | 36 | [SQL](sql/04_ctes.sql) |
| SQL 5: Window functions | 38–39 | [SQL](sql/05_window_functions.sql) |
| dbt 1: Project | 51 | [Answer](dbt/README.md#1-create-the-project) |
| dbt 2: Sources | 57 | [Answer](dbt/README.md#2-declare-sources-and-build-models) |
| dbt 3: Materializations | 59 | [Answer](dbt/README.md#3-choose-tables-or-views) |
| dbt 4: Documentation | 63 | [Answer](dbt/README.md#4-explore-documentation) |
| dbt 5: Tests | 71 | [Answer](dbt/README.md#5-detect-invalid-output) |
| dbt 6: Selectors | 77–78 | [Answer](dbt/README.md#6-select-models-from-the-example-graph) |
| dbt 7: Variables | 84 | [Answer](dbt/README.md#7-filter-with-date-variables) |
| dbt 8: Loops | 89 | [Answer](dbt/README.md#8-generate-status-counts) |
| dbt 9: Macros | 94 | [Answer](dbt/README.md#9-reuse-the-date-filter) |
| dbt 10: Seeds and snapshots | 120–121 | [Answer](dbt/README.md#10-upload-a-seed-and-record-history) |
| dbt 11: Country report | 122 | [Answer](dbt/README.md#11-build-the-country-report) |
