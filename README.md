# Data Minded Academy - dbt
## Exercises Repository

[![Open in
Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/datamindedacademy/academy_dbt.git)
[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/datamindedacademy/academy_dbt)

This repository is hosting the exercises provided to students in the context of the dbt course of the Data Minded Academy.

To start click on "Open in codespaces" button.

### Connection to Snowflake

In the first exercise, we will use `dbt init` to set up a connection to the Snowflake
data warehouse.

The connection details are not stored in the workspace itself (but in `~/.dbt/profiles.yml` instead)
so every time the workspace times out, the connection settings are lost. In that case, you can
run the script `/workspace/create_profiles.sh` to re-generate this file easily.

In case you want to experiment with dbt without Snowflake credentials, you can use the
[dbt Playground](https://github.com/datamindedacademy/dbt_playground) workspace, which uses a local
Postgres database as the data warehouse.

### Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
