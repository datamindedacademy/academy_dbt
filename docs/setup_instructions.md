# Setup instructions

This repository can be used with 2 databases to run SQL / dbt on:

- **Postgres:** No setup required. Everything is self-hosted inside the codespace.
- **Snowflake:** Accounts must be created and students must set up Duo MFA.

## Postgres

No setup is required. As part of the codespace, a local Postgres database is spun up
with the following credentials:

* hostname: db
* port: 5432
* database: postgres
* username: postgres
* password: postgres

The data can be queried in 3 ways:

- A VSCode extension SQLTools with the right driver and connection details.
  Click the SQLTools on the left to use it.
- A PGAdmin container is also part of this codespace.
  Click on Ports > click on the URL of the forwarded address of port 5052
  (looks like codespacename-5052.app.github.dev) to use it.
- Using dbt.

## Snowflake

To use this course with Snowflake, the following setup is required:

### Before the course

- Create a database for the current course e.g. `SUMMERSCHOOL2025`.
- For each student:
  - Create a schema `DBT_<firstname>` in that database
  - Create a Snowflake user and credentials.
    See the script in `snowflake_setup.py`. Read the instructions there.
    Note that this script is not thoroughly tested.
    Note also that users are automatically exp

### Instructions for users to connect

Users connecting with Snowflake must, on first login to the UI,
change their password and set up Duo MFA.

**Important: the MFA must be Duo, not a generic authenticator!**
Generic authenticators do not work with dbt-snowflake.

To connect via `dbt`, the following line is required in `profiles.yml`:
```
    authenticator: username_password_mfa
```
Note that none of the 3 options in `dbt init` (password, SSO, keypair)
set this option, it must be manually added.
