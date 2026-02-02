# Data Minded Academy - dbt
## Exercises Repository

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/datamindedacademy/academy_dbt)

This repository is hosting the exercises provided to students in the context of the dbt course of the Dataminded Academy.

To start click on "Open in codespaces" button.

### Connecting to Postgres

You can connect to the Postgres database in one of three ways:

1. **Using SQLTools** (the VSCode extension): Click the extension icon on the left. It has the right credentials.
2. **Using PGAdmin:** Click on Ports > click on the URL of the forwarded address of port 5052.
3. **Using dbt:** Run `dbt init`, choose postgres, and enter the following credentials:
    * hostname: db
    * port: 5432
    * database: postgres
    * username: postgres
    * password: postgres

### Connecting to Snowflake

You can also use `dbt init` to set up a connection to the Snowflake data warehouse,
and modify the `profiles.yml` that is created to include:

```
    authenticator: username_password_mfa
```

The connection details are not stored in the workspace itself (but in `~/.dbt/profiles.yml` instead)
so every time the workspace times out, the connection settings are lost. In that case, you can
run the script `/workspace/create_profiles.sh` to re-generate this file easily.

### Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
