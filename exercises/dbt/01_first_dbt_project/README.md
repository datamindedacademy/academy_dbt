# Exercise 1 — Your first dbt project

## Goal

Create a dbt project from scratch, connect it to the database, run it, and
understand what dbt created for you.

## Why this matters

Everything in dbt happens inside a *project*: a folder with a fixed layout that
holds your models, tests, and configuration. Creating one and seeing `dbt run`
work end-to-end demystifies the whole tool.

## Concepts

**Models.** A dbt model is simply a `.sql` file containing a `SELECT` statement.
dbt turns each model into a table or view in the database, with the same name as
the file. You never write `CREATE TABLE` yourself — dbt generates that
boilerplate ("DDL") around your `SELECT`.

**Project layout.** `dbt init` scaffolds a project:

```
dbt_test/
├── dbt_project.yml   <- the project's configuration (required)
├── models/           <- your models (.sql files) live here
├── tests/
├── macros/
├── seeds/
└── ...
```

**Connection profile.** Database credentials do *not* live in the project (they
would end up in git!). They live in `~/.dbt/profiles.yml` in your home
directory. A project points at a profile by name (the `profile:` line in
`dbt_project.yml`). `dbt debug` tests the connection.

In this course a script generates that file for you, with a target for each
backend. So you skip the questions `dbt init` would ask.

## Exercise

1. In the repository root, create the project and its profile.
   If setup already creates `dbt_test`, skip `dbt init`.

   ```bash
   dbt init dbt_test --skip-profile-setup
   ./create_profiles.sh --target databricks
   ```

   > `--skip-profile-setup` tells `dbt init` not to ask for connection
   > details. Answering its questions would overwrite the profile and throw
   > away the second target.

2. Run `cd dbt_test`, then `dbt debug`. Is it successful?
3. Open **Catalog** in Databricks. Which tables appear in `samples.tpch`?
   Which tables appear in `workspace.dbt`? The `dbt` schema may not exist yet.
4. Run `dbt run`.
5. Refresh the Databricks catalog. Which tables and views appear now?
   In which schema did they appear?
6. Look around in the folder that dbt created:
   - What does `my_first_dbt_model` do?
   - What does `my_second_dbt_model` do?
7. Open `~/.dbt/profiles.yml`. Find the profile named `dbt_test` and its two
   targets. Which one is the default?

## Tips

- Every `dbt` command must run *inside* the project folder.
- Your models appear in the `dbt` schema, not in `tpch`. The raw tables live in
  `tpch`, and dbt must not overwrite them.
- Open `models/example/my_second_dbt_model.sql` and note the
  `{{ ref('my_first_dbt_model') }}` — that's how dbt links models together.
  Exercise 2 explains it.
- To repair the profile from inside `dbt_test`, run `../create_profiles.sh`.
- For the Postgres backup, generate the profile with `--target postgres`.
  Inspect the tables with SQLTools or pgAdmin.
