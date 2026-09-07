# Data Minded Academy - dbt
## SQL and dbt exercises

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/datamindedacademy/academy_dbt?ref=feature%2Fdatabricks-classroom-setup)

This repository contains exercises for the SQL & dbt course of the Dataminded Academy.

## Start the Databricks course

1. Open a codespace with the button above.
2. Follow [the setup instructions](docs/setup_instructions.md#databricks-free-edition) to create your Databricks workspace and token.
3. Copy `.env.example` to `.env`. Enter the host, warehouse HTTP path, and token.
4. Run these commands in the repository root:

```bash
dbt init dbt_test --skip-profile-setup
./create_profiles.sh --target databricks
dbt debug --project-dir dbt_test
dbt run --project-dir dbt_test
```

Skip `dbt init` if the `dbt_test` project already exists.
A successful `dbt debug` confirms the connection.
The example models appear in `workspace.dbt`.
The starter project contains one deliberate null value, so its `not_null` test fails until exercise 5 fixes it.

Use the Databricks SQL editor for the [SQL exercises](exercises/sql/).
Use the codespace terminal for the [dbt exercises](exercises/dbt/).
See [VS Code setup](docs/setup_instructions.md#sql-and-dbt-in-vs-code) for SQLTools and dbt Power User.

## Database targets

`./create_profiles.sh` selects Databricks when all three credentials exist.
Otherwise, it selects the local Postgres database in the codespace.
Run the script again from the repository root after each `dbt init` or container rebuild.

```bash
./create_profiles.sh --target databricks  # Databricks course
./create_profiles.sh --target postgres    # local backup
```

The script creates only the targets with complete settings, plus Postgres.
For the backup, use SQLTools or pgAdmin on port 5052.
Snowflake is optional; see [the setup instructions](docs/setup_instructions.md).

Exercise 11 includes a TPC-H capstone with the existing sample data.
The Covid version needs separate data and SQL changes.

## Resources

- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
