# Part 2 — dbt

## What is dbt?

Writing one SQL query is easy. Maintaining *hundreds* of them is not:

- Many queries reuse the same logic — how do you avoid copy-paste?
- Queries depend on each other — how do you run them in the right order?
- How do you test that the data (and your queries) meet expectations?
- How do multiple developers collaborate on the same SQL?

**dbt** (data build tool) answers these. It is a command-line tool that does the
"T" in ELT (Extract, Load, **Transform**): it takes SQL `SELECT` statements you
write (called *models*), compiles them, and runs them against your database in
the right order. On top of that it gives you testing, documentation, and
templating — good practices borrowed from software engineering.

Two flavours exist: **dbt Core** (the free, open-source CLI — what we use) and
**dbt Cloud** (a hosted service around it).

## How these exercises work

Unlike the SQL part, the dbt exercises **build on each other**: you create one
dbt project in exercise 1 and extend it in every following exercise. Do them in
order. If you get stuck, check the corresponding `solutions/*` branch of this
repository.

| # | Topic | You learn |
|---|---|---|
| [01](01_first_dbt_project/) | Your first dbt project | `dbt init`, `dbt debug`, `dbt run`, models |
| [02](02_sources_and_staging/) | Sources and staging models | `source()`, `ref()`, the DAG |
| [03](03_materializations/) | Materializations | view vs table, config precedence |
| [04](04_documentation/) | Documentation | `dbt docs generate`, `dbt docs serve`, lineage |
| [05](05_testing/) | Testing | generic tests, singular tests, `dbt test` |
| [06](06_running_specific_models/) | Running specific models | `--select`, graph operators, tags |
| [07](07_jinja_variables/) | Jinja: variables | `var()`, vars in `dbt_project.yml` |
| [08](08_jinja_for_loops/) | Jinja: for loops | `{% for %}`, DRY SQL |
| [09](09_macros/) | Macros and packages | `{% macro %}`, dbt packages |
| [10](10_seeds_and_snapshots/) | Seeds and snapshots | `dbt seed`, `dbt snapshot`, history |
| [11](11_capstone_covid/) | Capstone: migrate SQL to dbt | everything combined |

## Connection details (used throughout)

Run `./create_profiles.sh` in the repository root once. It writes
`~/.dbt/profiles.yml` with two targets, so you can run every exercise on
either backend:

| | `postgres` target (default) | `databricks` target |
|---|---|---|
| where | the local database in the codespace | your Free Edition workspace |
| host | `db`, port `5432` | your workspace URL |
| user | `postgres` / `postgres` | a personal access token |
| source data | database `postgres`, schema `tpch` | catalog `samples`, schema `tpch` |
| your models | schema `dbt` | catalog `workspace`, schema `dbt` |

Switch backend with `--target`:

```bash
dbt run                        # postgres (the default target)
dbt run --target databricks    # the same code on Databricks
```

The Databricks target needs a `.env` file. See
[`docs/setup_instructions.md`](../../docs/setup_instructions.md).

> **Your models never land in the `tpch` schema.** The raw tables live there.
> dbt writes your models into the `dbt` schema, so a model named `customer`
> cannot replace the raw `customer` table.

## Cheat sheet: terminal commands

You will use the terminal a lot. The essentials:

| Command | What it does |
|---|---|
| `cd x` | change current directory to `x` |
| `ls` | show files in the current directory |
| `pwd` | print the current working directory |
| `code x` | open file `x` in the editor |
| `Ctrl-C` | stop the currently running command |
| `.` / `..` / `~` | current directory / one up / home directory |
| `~/.dbt/` | where dbt stores its configuration (`profiles.yml`) |
