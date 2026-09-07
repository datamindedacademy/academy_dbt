# dbt exercises

Use the `dbt_academy` project throughout exercises 1–11.
Run dbt commands inside that folder unless an exercise specifies the repository root.
Exercise 6 uses a diagram and requires no model files.

Complete the [setup](../../docs/setup_instructions.md#databricks-free-edition) first.
Databricks supplies the source tables in `samples.tpch`; your models appear in `workspace.dbt`.
For the Postgres backup, generate profiles with `--target postgres`.

| Exercise | Topic |
|---|---|
| [1](01_first_dbt_project/) | Create a project |
| [2](02_sources_and_staging/) | Sources and staging models |
| [3](03_materializations/) | Tables and views |
| [4](04_documentation/) | Documentation |
| [5](05_testing/) | Data tests |
| [6](06_running_specific_models/) | Model selection |
| [7](07_jinja_variables/) | Date variables |
| [8](08_jinja_for_loops/) | Jinja loops |
| [9](09_macros/) | Macros and packages |
| [10](10_seeds_and_snapshots/) | Seeds and snapshots |
| [11](11_capstone_covid/) | TPC-H capstone |
