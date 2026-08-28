# Setup instructions

This repository supports 3 databases to run SQL / dbt on:

- **Databricks Free Edition:** Each student creates a free personal workspace.
  This is the default for the on-site course.
- **Postgres:** No setup required. Everything is self-hosted inside the
  codespace. This is the backup, and the choice for the self-service track.
- **Snowflake:** Optional. Use it when a client group asks for it.

You can use all of them from the same dbt project. `create_profiles.sh` writes
one profile with a target per backend. Switch with `--target`.

Start the codespace first:

1. Go to https://codespaces.new/datamindedacademy/academy_dbt
2. Click **Create codespace** (don't change settings).
3. Wait a few minutes for the devcontainer to build.

## Generate your dbt profile

Run this once in the repository root:

```bash
./create_profiles.sh
```

It writes `~/.dbt/profiles.yml`. Useful options:

```bash
./create_profiles.sh --target databricks   # make databricks the default target
./create_profiles.sh --target snowflake    # make snowflake the default target
./create_profiles.sh my_project            # also write a profile 'my_project'
./create_profiles.sh --help
```

It writes to your HOME directory (`~/.dbt/profiles.yml`), so dbt, `dbt init`
and the VS Code extensions all find it.

The script writes a profile for every dbt project it finds in the repository,
so **re-run it after you create a project with `dbt init`**. It is safe to run
any number of times.

### Creating a dbt project

`dbt init` asks for connection details and **overwrites** the profile of the
same name, which throws away the second target. Skip its questions instead:

```bash
dbt init my_project --skip-profile-setup --skip-debug
./create_profiles.sh        # picks up the new project
cd my_project
dbt debug                   # tests the default target
dbt debug --target databricks
```

If you already overwrote a profile by accident, just run
`./create_profiles.sh` again. It repairs the file.

## Postgres (default, zero setup)

The codespace runs a local Postgres database with the TPC-H data preloaded.

| Setting | Value |
|---|---|
| hostname | `db` |
| port | `5432` |
| database | `postgres` |
| username | `postgres` |
| password | `postgres` |
| source data | schema `tpch` |
| your models | schema `dbt` |

> **Why two schemas?** The raw tables live in `tpch`. dbt writes your models
> into `dbt`. If dbt wrote into `tpch`, a model named `customer` would replace
> the raw `customer` table and destroy your source data.

Query the data in 3 ways:

- **SQLTools** (VSCode extension): click the SQLTools icon on the left.
  The connection is preconfigured.
- **pgAdmin**: open the **Ports** tab and click the forwarded URL of port 5052.
- **dbt**: run `./create_profiles.sh`, then `dbt debug` inside a project.

## Databricks Free Edition

Each student works in their own free workspace. One-time setup:

### 1. Create a workspace

- Sign up at https://www.databricks.com/learn/free-edition
  (email + one-time code, or a Google/Microsoft account).
- Note the workspace URL. It looks like
  `dbc-a1b2c3d4-e5f6.cloud.databricks.com`.

### 2. Create a personal access token

- **Settings > Developer > Access tokens > Manage > Generate new token**.
- Copy the token (it starts with `dapi`). You cannot view it again later.

### 3. Find the warehouse HTTP path

- **SQL Warehouses > Serverless Starter Warehouse > Connection details**.
- Copy the **HTTP path** (it looks like `/sql/1.0/warehouses/<id>`).

### 4. Configure the codespace

- Copy `.env.example` to `.env` and fill in the three values.
  `.env` is gitignored — never commit your token.
- Run `./create_profiles.sh`.
- Test with `dbt debug --target databricks` inside a dbt project.

### Using Databricks in the exercises

- Add `--target databricks` to any dbt command, e.g.
  `dbt run --target databricks`.
- The TPC-H source data is built in: catalog `samples`, schema `tpch`.
- Your models land in catalog `workspace`, schema `dbt`.
- You can also query interactively in the workspace's **SQL editor**.

### Notes and limits

- A rebuilt codespace loses `~/.dbt/profiles.yml`. Re-run
  `./create_profiles.sh`.
- Free Edition limits: one workspace per account, one 2X-Small serverless
  warehouse, max 5 concurrent job tasks. Fine for this course.
- Databricks may delete inactive accounts. Revoke tokens you no longer use
  (**Settings > Developer > Access tokens**).

### The Databricks VS Code extension

`create_profiles.sh` also writes an `[academy]` profile to `~/.databrickscfg`,
which is the file the Databricks extension reads. Other profiles in that file
are kept.

1. Open the Databricks icon in the left sidebar.
2. Choose **Configure** and pick the `academy` profile.
3. You can now browse the catalog and run SQL from the editor, without a job.

## Snowflake

Use Snowflake only when a client group asks for it. Two things to know first:

- **Password sign-in for dbt stops on 31 August 2026.** Snowflake removes
  single-factor password logins in phases through October 2026.
- **Key-pair authentication is the answer, not disabling MFA.** A key pair
  needs no second factor, so it is the supported way to connect a tool like
  dbt. It also removes the Duo problem that made us drop Snowflake before.

### 1. Create a key pair

Each student runs this once, in the codespace:

```bash
mkdir -p ~/.snowflake
openssl genrsa 2048 | openssl pkcs8 -topk8 -inform PEM -nocrypt -out ~/.snowflake/rsa_key.p8
openssl rsa -in ~/.snowflake/rsa_key.p8 -pubout -out ~/.snowflake/rsa_key.pub
chmod 600 ~/.snowflake/rsa_key.p8
cat ~/.snowflake/rsa_key.pub
```

Send the **public** key (`rsa_key.pub`) to the instructor. Never send the
private key (`rsa_key.p8`).

> Add `-v2 aes-256-cbc` to the `pkcs8` command if you want a passphrase on the
> key. Then set `SNOWFLAKE_PRIVATE_KEY_PASSPHRASE` in `.env`.

### 2. The instructor registers the public key

Paste the key body without the header, the footer, and the line breaks:

```sql
ALTER USER winterschool_tarik SET RSA_PUBLIC_KEY='MIIBIjANBgkq...';
```

### 3. Configure the codespace

Copy `.env.example` to `.env` and fill in the Snowflake block:

```
SNOWFLAKE_ACCOUNT=<orgname>-<account_name>
SNOWFLAKE_USER=winterschool_<your first name>
SNOWFLAKE_PRIVATE_KEY_PATH=~/.snowflake/rsa_key.p8
SNOWFLAKE_ROLE=student
SNOWFLAKE_WAREHOUSE=COMPUTE_WH
SNOWFLAKE_DATABASE=WINTERSCHOOL
```

Then run `./create_profiles.sh` and test with
`dbt debug --target snowflake`.

### Using Snowflake in the exercises

- The TPC-H source data is built in: database `SNOWFLAKE_SAMPLE_DATA`, schema
  `TPCH_SF1`. Every account has it.
- Your models land in `SNOWFLAKE_DATABASE`, schema `dbt`.

## One source declaration for every backend

The source data sits in a different place per backend. Let dbt pick the right
one, so the same project runs on all three:

```yaml
sources:
  - name: tpch
    database: >-
      {%- if target.type == 'databricks' -%}samples
      {%- elif target.type == 'snowflake' -%}SNOWFLAKE_SAMPLE_DATA
      {%- else -%}postgres
      {%- endif -%}
    schema: "{{ 'TPCH_SF1' if target.type == 'snowflake' else 'tpch' }}"
    tables:
      - name: customer
      - name: orders
```
