# Databricks setup

Follow these steps in order. Use your own Databricks workspace.
Databricks stores the data and runs SQL. Your Codespace runs dbt.
Run all terminal commands from the repository folder, `/workspaces/academy_dbt`.

## 1. Open your Codespace and Databricks workspace

1. Open the [course Codespace page](https://codespaces.new/datamindedacademy/academy_dbt?ref=main).
2. Select **Create codespace**. Wait for the setup to finish.
3. Open [Databricks Free Edition](https://www.databricks.com/learn/free-edition) and create your account.
4. Keep both browser tabs open.

Skip this step if both are already open.
The Codespace includes dbt and the Databricks adapter. Keep the installed versions for the course.

## 2. Copy the host and HTTP path

The SQL warehouse runs your queries.

1. In Databricks, select **SQL Warehouses**.
2. Open the available warehouse, usually **Serverless Starter Warehouse**.
3. Select **Connection details**.
4. Copy **Server hostname** and **HTTP path** into a temporary note.

Use the server hostname from this page. Do not copy the browser address.
See the [Databricks connection instructions](https://docs.databricks.com/aws/en/integrations/compute-details).

## 3. Create and copy your token

A personal access token lets dbt connect to your workspace.

1. Open your Databricks user menu and select **Settings**.
2. Select **Developer**.
3. Beside **Access tokens**, select **Manage**.
4. Select **Generate new token**.
5. Enter the name `academy-dbt` and a lifetime of **7 days**.
6. If Databricks asks for a scope type, select **BI Tools**.
7. Select **Generate**. Copy the token before you close the dialog.

Use a token from the same workspace as your host.
Keep it private. Do not paste it into chat or commit it to Git.
See the [Databricks token instructions](https://docs.databricks.com/aws/en/dev-tools/auth/pat).

## 4. Save the three values in .env

In the **Codespace terminal**, copy the example file:

```bash
cp .env.example .env
code .env
```

If `.env` already exists, open it with `code .env`. Do not copy the example again.
Replace the three empty Databricks values with your own values:

```dotenv
DATABRICKS_HOST=your_server_hostname
DATABRICKS_HTTP_PATH=/sql/1.0/warehouses/your_warehouse_id
DATABRICKS_TOKEN=your_token
```

The values above are placeholders. Use your actual connection details.
Do not add spaces around `=`. Leave the other settings unchanged and save the file.
Git ignores `.env`.

## 5. Create the Databricks profile

In the **Codespace terminal**, run:

```bash
./create_profiles.sh --target databricks
```

The script reads `.env` and writes the dbt connection profile to `~/.dbt/profiles.yml`.
It also creates a link named `profiles.yml` in the repository folder.
Open `profiles.yml` in the Codespace Explorer to see the connection settings.
Both paths open the same file. Git ignores the link because the file contains your token.
It selects Databricks and includes the profile for the course project, `dbt_academy`.
The default destination is catalog `workspace`, schema `dbt`.

The script replaces `~/.dbt/profiles.yml`. Back up that file first if it contains profiles from another course.

## 6. Create the dbt project and test the connection

In the **Codespace terminal**, run:

```bash
dbt init dbt_academy --skip-profile-setup
dbt debug --project-dir dbt_academy
```

Skip the first command if `dbt_academy` already exists.
The `--skip-profile-setup` option keeps the connection profile from step 5.

The final output should include:

```text
Connection test: [OK connection ok]
All checks passed!
```

If the connection fails, use the error table below before you continue.

## 7. Run your first SQL query

In the **Databricks SQL editor**, create a query and select your SQL warehouse.
Run:

```sql
SELECT c_custkey, c_name
FROM samples.tpch.customer
ORDER BY c_custkey
LIMIT 5;
```

You should see five customers.
The sample data already exists in Databricks. You do not upload it from your Codespace.
Use full table names, such as `samples.tpch.customer`, in the SQL exercises.

## 8. Run your first dbt models

In the **Codespace terminal**, run:

```bash
dbt run --project-dir dbt_academy
```

In Databricks, open **Catalog > workspace > dbt**. Refresh the catalog if needed.

| Model | Expected output |
|---|---|
| `my_first_dbt_model` | Two rows: `id` values `1` and `NULL` |
| `my_second_dbt_model` | One row: `id` value `1` |

The starter project includes a deliberate `not_null` test failure.
Exercise 5 fixes the null value. Use `dbt run` for this setup.

Use the Codespace terminal for dbt models. Use the Databricks SQL editor for plain SQL.
dbt resolves expressions such as `ref()` before it sends SQL to Databricks.

Continue with the [SQL exercises](../exercises/sql/) and [dbt exercises](../exercises/dbt/).
The project from step 6 also serves as your project for dbt exercise 1.

## Connection errors

| Problem | Action |
|---|---|
| Incomplete Databricks settings | Fill all three values in `.env`, save it, and repeat step 5. |
| Invalid token or HTTP 401/403 | Check the token's workspace, expiry, scopes, and warehouse permissions. Replace the token if needed. Repeat step 5. |
| Token creation is unavailable | Check the workspace token permissions with your instructor. |
| Could not find profile | Repeat step 5, then repeat `dbt debug --project-dir dbt_academy`. |
| Connection works, but models fail | Check access to catalog `workspace` and permission to create objects in schema `dbt`. |
| Cannot find the sample table | Use the full name `samples.tpch.customer`. |
| Warehouse quota reached | Ask your instructor for help. The workspace cannot run more queries until its quota resets. |

## Replace your token

Create a new token in the same workspace. Replace `DATABRICKS_TOKEN` in `.env` and save the file.
Run:

```bash
./create_profiles.sh --target databricks
dbt debug --project-dir dbt_academy
```

Repeat these commands after a Codespace rebuild.
