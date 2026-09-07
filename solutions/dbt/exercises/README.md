# Completed dbt exercises

This project contains the completed models for dbt exercises 1–11.
Read the [exercise answers](../README.md) for each intermediate step and expected result.
Exercise 6 is a command exercise with a separate example graph.

## Run the completed project

Complete the [Databricks setup](../../../docs/setup_instructions.md).
Run from the repository root:

```bash
./create_profiles.sh --target databricks
dbt debug --project-dir solutions/dbt/exercises
dbt build --project-dir solutions/dbt/exercises
dbt show --project-dir solutions/dbt/exercises --select revenue_per_nation --limit 10
dbt show --project-dir solutions/dbt/exercises --select compare_country_report
```

The profile is `dbt_academy`. Models appear in `workspace.dbt` with the default profile settings.
This replaces the same named models as your exercise project.
The comparison returns zero rows when the dbt report matches the exercise's SQL.

This is the completed state: both starter models contain only `id = 1` after the fix from exercise 5.
`customer_stats` includes every customer and the three status counts.
The date interval includes January 1 through March 31, 1995.
The seed starts with five countries; follow exercise 10 to inspect later snapshot versions.

## Open the documentation

```bash
dbt docs generate --project-dir solutions/dbt/exercises
dbt docs serve --project-dir solutions/dbt/exercises --port 8080
```

Open port **8080** in Codespaces and inspect the model graph.
