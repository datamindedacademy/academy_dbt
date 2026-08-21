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

1. In the repository root, create the project and its profile:

   ```bash
   dbt init dbt_test --skip-profile-setup --skip-debug
   ./create_profiles.sh
   ```

   > `--skip-profile-setup` tells `dbt init` not to ask for connection
   > details. Answering its questions would overwrite the profile and throw
   > away the second target.

2. `cd dbt_test` and run `dbt debug`. Is it successful?
   Now try `dbt debug --target databricks`. Does that work too?
3. Connect to the database with SQLTools or pgAdmin (see
   [`../../sql/README.md`](../../sql/README.md)). Which tables/views are in
   schema `tpch`? And in schema `dbt`?
4. Run `dbt run`.
5. Which tables/views are there now? (In pgAdmin: right-click > Refresh.)
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
- Broke your profile? Run `./create_profiles.sh` again. It rewrites the file.
- Solution branch: `solutions/exercise_1`.
