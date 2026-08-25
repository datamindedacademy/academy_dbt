# Refactor plan: SQL & dbt course to self-service

State on 2026-08-25. Branch `feature/self-service-exercises` is pushed.
Read this to pick the work up cold.

## Why

Jan builds a knowledge hub for Dataminded. The summer school courses must
become self-serviceable. The exercises lived only in a slide deck, and the repo
was bare. So we moved every exercise into markdown, one folder per exercise.

Reference repo structures given by Jan: the Docker containerization repo, and
"Data Frame of Mind".

## Done

### Exercises (`exercises/`)

Every exercise from `docs/SQL & dbt Winterschool 2026.pptx` is now markdown.
The deck itself is untouched.

- `sql/` — 5 exercises: filtering, joins, aggregations, CTEs, window functions.
- `dbt/` — 11 exercises, in order: first project, sources and staging,
  materializations, docs, testing, model selection, Jinja variables, for loops,
  macros, seeds and snapshots, covid capstone.
- Each README has: goal, why this matters, concepts, the tasks, tips.
  Written for people who have never used dbt.
- The dbt exercises build one project step by step. The SQL exercises stand
  alone.

### Solutions (`solutions/`)

- `sql/01..05.sql` — every question answered.
- `dbt/02, 05, 07, 08, 09 .sql` — the dbt exercises whose answer is SQL, in
  compiled form, with the Jinja original in comments.
- `dbt/README.md` — the answers that are commands, YAML, or observations
  (exercises 1, 3, 4, 6, 10, 11).
- All 28 statements ran against Databricks `samples.tpch`. All passed.

### Two database backends

`create_profiles.sh` writes `~/.dbt/profiles.yml`. Every profile gets a
`postgres` target and a `databricks` target. Switch with `--target databricks`.

The documented flow:

```bash
dbt init my_project --skip-profile-setup --skip-debug
./create_profiles.sh          # picks up the new project
cd my_project
dbt run                       # postgres
dbt run --target databricks   # the same code on Databricks
```

Databricks credentials come from a gitignored `.env`. The template is
`.env.example`.

### Snowflake removed

Deleted `docs/snowflake_setup/`. Replaced `dbt-snowflake` with
`dbt-databricks` in the devcontainer. Cleaned the Snowflake references from
`README.md`, `docs/setup_instructions.md`, and the SQLTools settings.

## Three bugs we fixed

1. **`create_profiles.sh` knew only 2 profile names.** Any other project name
   failed with `Could not find profile named '<name>'`. The script now reads
   the `profile:` line of every `dbt_project.yml` in the repo. It also accepts
   extra names as arguments.
2. **`dbt init` destroyed the Databricks target.** Its interview overwrites the
   profile and writes one target. Measured: 3 Databricks references before, 2
   after. Fix: the docs use `--skip-profile-setup`, and re-running
   `create_profiles.sh` repairs an overwritten profile.
3. **Models built into the source schema.** The profile used `schema: tpch` for
   both sources and models. The `dbt_test` project has models named
   `customer.sql` and `orders.sql`, so `dbt run` dropped the raw
   `tpch.customer` and `tpch.orders` tables. Models now go to schema `dbt`.
   We restored both tables in the local devcontainer database from
   `.devcontainer/init-tpch.sql` (150 customers, 1500 orders).

## The portable source declaration

The source data sits in a different place per backend. This one line lets the
same project run on both:

```yaml
sources:
  - name: tpch
    database: "{{ 'samples' if target.type == 'databricks' else 'postgres' }}"
    schema: tpch
```

## Backend decision

`docs/database_choice_analysis.md` holds the full comparison. The
recommendation splits by course format:

- **On site: Databricks Free Edition.** You are in the room, so the signup
  friction costs guided minutes. Clients ask about Databricks constantly.
  `samples.tpch` is built in, which removes our data-load scripts.
- **Self-service: Postgres in the codespace.** Zero signup steps. An
  unattended learner who hits a signup problem quits.

Verified on a real Free Edition workspace: dbt Core 1.12 plus
`dbt-databricks` builds the exercise-2 models in 14 s, cold warehouse
included. Free Edition limits (one workspace, one 2X-Small warehouse, 5
concurrent tasks) are fine for this course.

## What is not done

1. **The covid capstone does not run.** The dataset is not in the codespace and
   not in Databricks `samples`. The starting views use Snowflake functions
   (`LAST_DAY`, `DATEADD`, `TO_VARCHAR`). Choose one:
   - upload the covid data to Databricks and port the functions, or
   - rewrite the capstone against TPC-H.
   The exercise carries a warning at the top until then.
2. **`dbt_test/` is untracked.** It is your scratch project. Decide whether it
   belongs in the repo. Its models are safe now, because models build into the
   `dbt` schema.
3. **The slide deck is untracked.** `docs/SQL & dbt Winterschool 2026.pptx` is
   14 MB. Git never had it, although we believed it was on `main`. Decide
   whether to commit a binary that size.
4. **No full run-through in a fresh codespace.** We tested against the running
   devcontainer database through a temporary tunnel, because the hostname `db`
   resolves only inside the codespace. Open a clean codespace and walk
   exercises 1 to 10 once.
5. **Solutions are not tested on Postgres.** They ran on Databricks. On
   Postgres, drop the `samples.` prefix. Question 4 of SQL exercise 1 uses
   `SUBSTRING` and `CAST`, which behave the same, but confirm it.
6. **Databricks exercise instructions are untested in a room.** Use the on-site
   edition as the test bed. Once they run smoothly, they can join the
   self-service track as an optional path.
7. **The pull request is open to create:**
   https://github.com/datamindedacademy/academy_dbt/pull/new/feature/self-service-exercises

## Security note

The Databricks token used for testing is in the chat history and in the shell
history of that session. It never entered git — `.env` is gitignored, and we
verified the staged content held no token and no workspace URL. Rotate the
token anyway: **Settings > Developer > Access tokens**.

The test also left a `dbt` schema with a few views in that Databricks
workspace, plus a `dbt_tarik` schema from the first probe. Delete them when you
want.

## Files that matter

| Path | What it is |
|---|---|
| `exercises/` | the course, one README per exercise |
| `solutions/` | runnable SQL and the command/YAML answers |
| `create_profiles.sh` | writes the dbt profile with both targets |
| `.env.example` | the credentials template students copy |
| `docs/setup_instructions.md` | setup for both backends |
| `docs/database_choice_analysis.md` | the backend comparison and decision |

## Follow-up with Jan

A follow-up was planned around 14 August. Target: show something during summer
school.
