# Course backend: Postgres + pgAdmin vs Databricks Free Edition

**Split by course format.**

- **On-site course: use Databricks Free Edition.** An instructor is in the room
  and sees every laptop. The signup friction (email OTP, PAT creation) costs a
  few guided minutes. Students leave with hands-on
  Databricks exposure.
- **Self-service track: keep Postgres in the codespace.** It is the only option
  with zero signup steps, and an unattended learner who hits a signup problem
  simply quits.

The exercises stay identical markdown in both cases; only the connection
chapter and the SQL dialect differ.

## Current setup (Postgres)

The codespace runs three containers via docker-compose:

- `postgres:17` with the TPC-H schema auto-loaded on first start
- `pgadmin4:9` on a forwarded port, preconfigured with the server connection
- the dev container itself, with dbt and the SQLTools VSCode extension

A student clicks one link, waits for the build, and can query. No account, no
password reset, no MFA. This matters most for the self-service goal: every
signup step loses unattended learners.

The "hacky" feel comes from pgAdmin on a forwarded port, not from Postgres
itself. SQLTools inside VSCode already covers most query needs. Dropping the
pgAdmin container is an option if we lean on SQLTools alone.

## Databricks Free Edition

Databricks now has [Free Edition](https://www.databricks.com/learn/free-edition):
a serverless-only, aimed at students and hobbyists.

What we verified:

- **Signup:** self-service with email OTP, Google, or Microsoft login. Each
  student creates their own workspace. No admin work on our side([signup docs](https://docs.databricks.com/aws/en/getting-started/free-edition)).
- **dbt Core works.** The workspace ships with a pre-created "Serverless
  Starter Warehouse". You cannot create more warehouses. `dbt-databricks`
  connects to it with a personal access token
  ([walkthrough](http://adamfortuno.com/index.php/2025/07/27/databricks-free-edition-with-dbt-core/),
  [Databricks dbt guide](https://docs.databricks.com/aws/en/partners/prep/dbt)).
- **Limits:** one workspace per account, one 2X-Small warehouse, max 5
  concurrent job tasks, no account console or account APIs, outbound access
  restricted to trusted domains, inactive accounts may be deleted, no SLA
  ([limitations](https://docs.databricks.com/aws/en/getting-started/free-edition-limitations)).

These limits are fine for a single-student course project.

## Comparison for this course

| Aspect | Postgres in codespace | Databricks Free Edition |
|---|---|---|
| Steps before first query | 0 (open codespace) | Sign up, verify email, open SQL editor |
| Steps before first `dbt run` | `dbt init` | Sign up, create PAT, find warehouse HTTP path, `dbt init` |
| Sample data | TPC-H preloaded | Databricks `samples` catalog has TPC-H built in; our covid data needs an upload notebook |
| Admin work per cohort | none | none (students self-register) |
| Failure modes we own | codespace build | none, but product limits can change under us |
| Account lifetime | n/a | deleted when inactive; a returning learner may restart |
| "Legitimacy" / sales value | none |  clients ask about Databricks |
| Exercise portability | plain Postgres SQL | small dialect changes (e.g. `DATEADD` exists, schema→catalog.schema) |
| Cost | free (codespace quota) | free |

## Verified: exercise 2 runs on Free Edition (2026-08-21)

We tested a real Free Edition workspace with dbt Core 1.12 + `dbt-databricks`:

- `dbt debug` connects with a personal access token and the
  Serverless Starter Warehouse (`/sql/1.0/warehouses/<id>`).
- The exercise-2 project (source `samples.tpch` → `stg_customer`,
  `stg_orders` → `customer_stats`) builds in 14 s, cold warehouse included.
- The built-in `samples.tpch` catalog holds ~500k customers. Exercise
  thresholds that return zero rows on our tiny local sample (e.g. "more than
  25 orders") work here as intended.
- Setup differences vs Postgres: the profile needs `catalog:` next to
  `schema:`, and the source declares `database: samples`.


## Summary

Two formats, two backends:

- **On-site:** Databricks Free Edition. The instructor absorbs the signup
  friction. The `samples.tpch` catalog removes our data-loading scripts, the
  covid capstone runs with minimal changes, and students gain exposure to a
  platform that generates client questions.
- **Self-service:** Postgres in the codespace, because a zero-friction start
  beats platform prestige for unattended learners.

Practical consequence: the on-site edition becomes the test bed for the
Databricks instructions. Once those instructions prove smooth in a room, they
can graduate into the self-service track as an optional path.

Sources: [Databricks Free Edition](https://www.databricks.com/learn/free-edition) ·
[Free Edition limitations](https://docs.databricks.com/aws/en/getting-started/free-edition-limitations) ·
[Sign up for Free Edition](https://docs.databricks.com/aws/en/getting-started/free-edition) ·
[Connect dbt Core to Databricks](https://docs.databricks.com/aws/en/partners/prep/dbt) ·
[Free Edition with dbt Core walkthrough](http://adamfortuno.com/index.php/2025/07/27/databricks-free-edition-with-dbt-core/)
