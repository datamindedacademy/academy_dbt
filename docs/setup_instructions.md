# Setup instructions

This repository supports 3 databases to run SQL / dbt on:

- **Databricks Free Edition:** Each student creates a free personal workspace.
  This is the default for the on-site course.
- **Postgres:** No setup required. Everything is self-hosted inside the
  codespace. This is the backup, and the choice for the self-service track.
- **Snowflake:** Optional. Use it when a client group asks for it.

The main course uses Databricks and its TPC-H sample tables.
`create_profiles.sh` writes one profile with a target per configured backend.

Start the codespace first:

1. Go to https://codespaces.new/datamindedacademy/academy_dbt?ref=feature%2Fdatabricks-classroom-setup
2. Select the course branch. Click **Create codespace**.
3. Wait a few minutes for the devcontainer to build.

## Generate your dbt profile

Run this once in the repository root:

```bash
./create_profiles.sh
```

It writes `~/.dbt/profiles.yml`. It selects Databricks when its credentials exist.
Otherwise, it selects Postgres. Useful options:

```bash
./create_profiles.sh --target databricks   # make databricks the default target
./create_profiles.sh --target snowflake    # make snowflake the default target
./create_profiles.sh my_project            # also write a profile 'my_project'
./create_profiles.sh --help
```

It writes to your HOME directory (`~/.dbt/profiles.yml`), so dbt, `dbt init`
and the VS Code extensions all find it.

The script writes a profile for every dbt project it finds in the repository,
so **re-run it after you create a project with `dbt init`**. The script replaces the file. Back up any profiles from other courses first.

### Creating a dbt project

`dbt init` asks for connection details and **overwrites** the profile of the
same name, which throws away the second target. Skip its questions instead:

```bash
dbt init my_project --skip-profile-setup
./create_profiles.sh        # picks up the new project
cd my_project
dbt debug                   # tests the default target
dbt debug --target databricks
```

If you already overwrote a profile by accident, just run
`./create_profiles.sh` again. It repairs the file.

## Postgres (local backup)

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

Each student needs a personal Databricks workspace and a GitHub Codespace.
Databricks stores the data and runs SQL. The codespace runs dbt.

### 1. Create your Databricks workspace

1. Open the [Free Edition signup page](https://www.databricks.com/learn/free-edition).
2. Select **Free Edition**. Complete the email or Google/Microsoft sign-in.
3. Wait for your workspace to open.
4. Keep this browser tab open for the SQL exercises.

Use your own workspace for every step below.

### 2. Get the warehouse connection details

The SQL warehouse is the compute service that runs your queries.

1. Open **SQL Warehouses** in the Databricks sidebar.
2. Open the existing warehouse, usually **Serverless Starter Warehouse**.
3. Open **Connection details**.
4. Copy the **Server hostname** and **HTTP path** into a temporary note.

| Field | Example |
|---|---|
| Server hostname | `dbc-a1b2c3d4-e5f6.cloud.databricks.com` |
| HTTP path | `/sql/1.0/warehouses/0123456789abcdef` |

Use the hostname from **Connection details**.
A browser URL with `/editor` or `?o=...` is not a hostname.

### 3. Generate a personal access token

A personal access token (`PAT`) lets dbt connect to your workspace.

1. Open your user menu in Databricks. Select **Settings**.
2. Select **Developer**.
3. Next to **Access tokens**, select **Manage**.
4. Select **Generate new token**.
5. Enter a name, such as `academy-dbt`.
6. Set a lifetime that covers the course, for example **7 days**.
7. If the form asks for a scope type, select **BI Tools** for SQL warehouse access.
8. Select **Generate**. Copy the token before you close the dialog.

Keep the token private. Save it only in your own `.env` file in the next step.
A token works only in the workspace that creates it.
If token creation is unavailable, check the workspace token permissions.
See the [Databricks token instructions](https://docs.databricks.com/aws/en/dev-tools/auth/pat).

### 4. Save the connection details in the codespace

Open the terminal in the codespace. Start from the repository root.
Copy the example only if you do not already have a `.env` file:

```bash
cp .env.example .env
code .env
```

Replace the three empty values in `.env` with your own values:

```dotenv
DATABRICKS_HOST=dbc-a1b2c3d4-e5f6.cloud.databricks.com
DATABRICKS_HTTP_PATH=/sql/1.0/warehouses/0123456789abcdef
DATABRICKS_TOKEN=paste_your_token_here
```

The values above are examples. Do not add spaces around `=`.
Save the file. Git ignores `.env`, so your token stays outside the repository history.

### 5. Create your dbt project and connection profile

Run these commands from the repository root:

```bash
dbt init dbt_test --skip-profile-setup
./create_profiles.sh --target databricks
dbt debug --project-dir dbt_test
```

Skip `dbt init` if the `dbt_test` project already exists.
The script writes your connection settings to `~/.dbt/profiles.yml`.
The project uses its `dbt_test` profile.

Check the final output from `dbt debug`:

```text
Connection test: [OK connection ok]
All checks passed!
```

If the connection fails, use the error table below.

### 6. Run SQL and your first dbt models

Open the Databricks **SQL editor** and create a query.
Select your SQL warehouse. Run this statement:

```sql
SELECT c_custkey, c_name
FROM samples.tpch.customer
ORDER BY c_custkey
LIMIT 5;
```

Use full table names such as `samples.tpch.customer` in each query tab.

In the codespace terminal, run this command from the repository root:

```bash
dbt run --project-dir dbt_test
```

Open **Catalog > workspace > dbt** in Databricks. Refresh the catalog if needed.
Inspect `my_first_dbt_model` and `my_second_dbt_model`.
The first model contains the identifiers `1` and `NULL`. The second model contains only `1`.

The starter project deliberately includes one failing `not_null` test.
`dbt test --project-dir dbt_test` reports that failure until exercise 5 fixes the example data.
This expected failure confirms that the test detects the null value.

| Purpose | Location |
|---|---|
| Original sample tables | `samples.tpch` |
| Your dbt models | `workspace.dbt` |
| SQL commands | Databricks SQL editor |
| dbt commands | Terminal in the codespace |

Continue with the [SQL exercises](../exercises/sql/) or [dbt exercises](../exercises/dbt/).
Exercise 1 uses the project you create in this setup.

### 7. Check the remaining dbt features

From the repository root, run the optional course check:

```bash
python checks/check_setup.py
```

The check reads all eight sample tables.
It tests views, a table, data tests, seeds, snapshot history, and documentation.
It creates a separate temporary schema and removes that schema after the check.
A successful check ends with `PASS`.

The [SQL exercises](../exercises/sql/) and [dbt exercises](../exercises/dbt/) remain available for optional practice.
Exercise 1 creates a separate starter project.

### Replace an expired token or rebuild a codespace

Generate a new token in the same workspace. Replace `DATABRICKS_TOKEN` in `.env`.
From the repository root, run:

```bash
./create_profiles.sh --target databricks
dbt debug --project-dir dbt_test
```

The script copies the token into the profiles.
A change to `.env` takes effect after you rerun the script.
Rerun the script after a codespace rebuild or after each new `dbt init`.
To end access after the course, revoke the token under **Settings > Developer > Access tokens**.

### Connection errors

| Error | Action |
|---|---|
| `Invalid access token` or HTTP 401/403 | Create a token in the same workspace as the hostname. Update `.env` and rerun the profile script. |
| Access denied with a valid token | Check token scopes and permission to use the SQL warehouse. |
| `No such option: --skip-debug` | Use `dbt init dbt_test --skip-profile-setup`. |
| `Could not find profile` | Rerun the profile script after you create the project. |
| No `databricks` target | Complete all three Databricks settings in `.env`. Rerun the profile script. |
| Cannot find `tpch.customer` | Select the `samples` catalog or use `samples.tpch.customer`. |
| Connection succeeds, but `dbt run` fails | Check access to the destination catalog and schema. The defaults are `workspace.dbt`. |
| The warehouse stops after a quota limit | Use the Postgres backup for the rest of the course. |

Use `./create_profiles.sh --target databricks` from the repository root.
Use `../create_profiles.sh --target databricks` from inside `dbt_test`.
For the backup, select `--target postgres` and use SQLTools or pgAdmin.

### SQL and dbt in VS Code

Use the tool that matches the file:

| File | Tool |
|---|---|
| Standalone SQL files | SQLTools with the Databricks driver, or the Databricks SQL editor |
| Models under `dbt_test/models/` | dbt Core or dbt Power User |
| Databricks notebooks and Python jobs | The Databricks extension |

A dbt model belongs to a project with a `dbt_project.yml` file.
Run the model through dbt so it can resolve its references.

The Databricks extension does not support SQL warehouses as its execution target.
It does not compile dbt `ref()`, `source()`, or Jinja expressions. [Databricks extension requirements](https://docs.databricks.com/aws/en/dev-tools/vscode-ext/install)

#### Run plain SQL with SQLTools

The container includes SQLTools and `databricks.sqltools-databricks-driver`.
For an existing container, install the driver from Extensions or rebuild the container.

1. Open SQLTools and select **Add New Connection**.
2. Select the **Databricks** driver.
3. Select **Hostname and Token**.
4. Enter the host, HTTP path, and token from your Databricks setup.
5. Use catalog `samples` and schema `tpch` for the SQL examples.
6. Test and save the connection in your local user settings.
7. Select one query in a SQL file, then select **Run Selected Query**.

Use the SQL language mode for these standalone files.
Keep tokens out of the repository's shared settings.
Use catalog `workspace` and schema `dbt` to inspect your dbt output. [Databricks SQLTools guide](https://docs.databricks.com/aws/en/dev-tools/sqltools-driver)

#### Run dbt models

Use the course container. Run these commands from the repository root:

```bash
./create_profiles.sh --target databricks
dbt run --project-dir dbt_test
```

For dbt Power User, select the Python interpreter that contains dbt Core and `dbt-databricks`.
Keep the integration setting at `core`.
The extension discovers `dbt_project.yml` inside your project folder.
Use a model's dbt actions to compile or run it.
The Databricks play button uses a different execution path.

If `dbt --version` prints `dbt Cloud CLI`, reopen the course container to use dbt Core.

#### The optional Databricks extension

The profile script also writes an `academy` profile to `~/.databrickscfg`.
Open the Databricks icon in VS Code. Select **Configure**, then the `academy` profile.
This profile connects the extension to the workspace.
It does not replace the dbt profile or configure a SQLTools warehouse connection.

### Free Edition limits

Free Edition provides one small SQL warehouse per workspace.
Usage quotas can stop compute for the day.
See the [current limits](https://docs.databricks.com/aws/en/getting-started/free-edition-limitations).

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
