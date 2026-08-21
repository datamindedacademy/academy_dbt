# Data Minded Academy - dbt
## Exercises Repository

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/datamindedacademy/academy_dbt)

This repository hosts the exercises of the SQL & dbt course of the Dataminded Academy.

To start, click the "Open in GitHub Codespaces" button above, then work through
the exercises in [`exercises/`](exercises/).

## Database backends

The course runs on one of two databases (full instructions in
[`docs/setup_instructions.md`](docs/setup_instructions.md)):

- **Postgres** (default, zero setup): a local database inside the codespace,
  with the TPC-H sample data preloaded. Query it via the SQLTools extension,
  via pgAdmin (forwarded port 5052), or via dbt.
- **Databricks Free Edition** (on-site course): each student creates a free
  personal workspace. Copy `.env.example` to `.env` and fill in your workspace
  URL, warehouse HTTP path, and access token.

Run `./create_profiles.sh` once. It generates `~/.dbt/profiles.yml` with a
`postgres` target and a `databricks` target in every profile, so the same
project runs on either backend:

```bash
dbt init my_project --skip-profile-setup --skip-debug
./create_profiles.sh          # picks up the new project
cd my_project
dbt run                       # postgres
dbt run --target databricks   # the same code on Databricks
```

Re-run `./create_profiles.sh` any time — after `dbt init`, after a codespace
rebuild, or to repair the file.

## Resources

- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
