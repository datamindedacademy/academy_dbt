# Data Minded Academy - dbt
## Exercises Repository

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/datamindedacademy/academy_dbt)

This repository hosts the exercises of the SQL & dbt course of the Dataminded Academy.

To start, click the "Open in GitHub Codespaces" button above, then work through
the exercises in [`exercises/`](exercises/).

## Database backends

The course runs on one of three databases (full instructions in
[`docs/setup_instructions.md`](docs/setup_instructions.md)):

- **Postgres** (default, zero setup): a local database inside the codespace,
  with the TPC-H sample data preloaded. Query it via the SQLTools extension,
  via pgAdmin (forwarded port 5052), or via dbt.
- **Databricks Free Edition** (on-site course): each student creates a free
  personal workspace. Copy `.env.example` to `.env` and fill in your workspace
  URL, warehouse HTTP path, and access token.
- **Snowflake**: works with any Snowflake account — a trial, your employer's, or
  a classroom your instructor set up. Fill in the `SNOWFLAKE_*` values in `.env`
  and use an access token or a key pair.

Run `./create_profiles.sh` once. It generates `~/.dbt/profiles.yml` with a
target per backend you have configured, so the same project runs on any of them:

```bash
dbt init my_project --skip-profile-setup --skip-debug
./create_profiles.sh          # picks up the new project
cd my_project
dbt run                       # postgres
dbt run --target databricks   # the same code on Databricks
dbt run --target snowflake    # or on Snowflake
```

Re-run `./create_profiles.sh` any time — after `dbt init`, after a codespace
rebuild, or to repair the file.

## For instructors running a classroom

You do not need this to do the exercises — it is only for teaching them.

[`instructor/`](instructor/) holds Terraform that provisions a whole class at
once: a Snowflake account with one user, role and schema per participant, each
plus a programmatic access token for dbt and a throwaway AWS Cognito identity for
the Snowflake web UI. Students get one username, no MFA enrolment, and no
Snowflake account of their own to create.

## Resources

- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
