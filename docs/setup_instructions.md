# Setup instructions

This repository supports 2 databases to run SQL / dbt on:

- **Postgres:** No setup required. Everything is self-hosted inside the codespace.
  Use this for the self-service track.
- **Databricks Free Edition:** Each student creates a free personal workspace.
  Use this for the on-site course.

You can use both from the same dbt project: `create_profiles.sh` writes one
profile with a `postgres` target and a `databricks` target. Switch with
`--target`.

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
./create_profiles.sh my_project            # also write a profile 'my_project'
./create_profiles.sh --help
```

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

### One source declaration for both backends

The source data sits in a different place per backend (`samples` on Databricks,
`postgres` on Postgres). Let dbt pick the right one, so the same project runs
on both:

```yaml
sources:
  - name: tpch
    database: "{{ {'databricks': 'samples', 'snowflake': 'snowflake_sample_data'}.get(target.type, 'postgres') }}"
    schema: "{{ 'tpch_sf1' if target.type == 'snowflake' else 'tpch' }}"
    tables:
      - name: customer
      - name: orders
```

### Notes and limits

- A rebuilt codespace loses `~/.dbt/profiles.yml`. Re-run
  `./create_profiles.sh`.
- Free Edition limits: one workspace per account, one 2X-Small serverless
  warehouse, max 5 concurrent job tasks. Fine for this course.
- Databricks may delete inactive accounts. Revoke tokens you no longer use
  (**Settings > Developer > Access tokens**).

## Snowflake

Two ways to get here, and they differ only in where the credentials come from.

**Your own account.** Anything with a Snowflake account works — a trial, your
employer's, whatever. Fill in `.env` yourself and pick an authentication method
below.

**A classroom your instructor set up.** You receive a ready-made `.env` with your
own user, role and schema. Nothing to sign up for, nothing to fill in.

### Authentication

`create_profiles.sh` picks the method from whichever variable is set in `.env`:

| `.env` variable | Method | Notes |
| --- | --- | --- |
| `SNOWFLAKE_PASSWORD` | Access token or password | A [programmatic access token](https://docs.snowflake.com/en/user-guide/programmatic-access-tokens) goes here — it replaces the password. This is what a classroom handout contains. |
| `SNOWFLAKE_PRIVATE_KEY_PATH` | Key pair | The alternative on your own account. Exempt from MFA, no browser. |

Both also work with the **Snowflake VS Code extension**: `create_profiles.sh`
writes `~/.snowflake/connections.toml` alongside your dbt profile, so you can run
SQL in the editor as well as through dbt.

dbt also supports `authenticator: externalbrowser`, but **not in a codespace**: it
waits for a redirect to `localhost`, which in a codespace is the container rather
than your laptop. Use a key pair instead.

To set up a key pair on your own account, see [Snowflake's key-pair
guide](https://docs.snowflake.com/en/user-guide/key-pair-auth), then point
`SNOWFLAKE_PRIVATE_KEY_PATH` at the private key file.

### 1. Install the file

Put your `.env` in the root of this repository — the one your instructor gave
you, or one you filled in yourself from `.env.example`. Then:

```bash
./create_profiles.sh
```

You should see a `snowflake` line in the summary it prints.

### 2. Check it works

```bash
dbt debug --target snowflake
```

Nothing expires during a course, so there is no daily step.

### Using Snowflake in the exercises

```bash
dbt run --target snowflake
```

Your models are written to your own schema in the shared course database. You
can read the TPC-H source tables at `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1`, and you
cannot write to another participant's schema.

### The web UI (classroom setup only)

Your instructor's setup also gives you Snowsight, the Snowflake web UI, at the
account URL in your `.env`. Sign in with the **"Academy login"** button rather
than the username and password fields — your Snowflake user has no password of
its own, and the fields will refuse you. The button takes you to a login page
where the username and password from your handout work.

### Notes and limits

- The warehouse is shared with the rest of the class and suspends after a minute
  of inactivity. A first query after a pause takes a few seconds to wake it.
- A rebuilt codespace loses `~/.dbt/profiles.yml` and `~/.snowflake/connections.toml`.
  Re-run `./create_profiles.sh`.
