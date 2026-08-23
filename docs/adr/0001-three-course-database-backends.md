# 1. Three database backends, one dbt project

Date: 2026-08-23 · Status: accepted

## Context

The course runs in two formats, and they fail differently. On-site, an
instructor is in the room and sees every laptop, so signup friction costs a few
guided minutes. Self-service, an unattended learner who hits a signup problem
does not file a ticket — they quit. Every account step is a drop-off point.

We also want students to leave having touched a platform clients ask about.
That argues for a cloud warehouse; the drop-off argument argues against one.

## Decision

Support three backends from the same dbt project. `create_profiles.sh` writes
`~/.dbt/profiles.yml` with one target per backend the student has configured,
so the same models run on any of them via `--target`.

| Backend | For | Steps before first query |
| --- | --- | --- |
| Postgres in the codespace (default) | self-service | 0 — open the codespace |
| Databricks Free Edition | on-site | sign up, create a PAT, find the warehouse HTTP path |
| Snowflake | classroom or own account | fill in `SNOWFLAKE_*` in `.env` — see [ADR 2](0002-snowflake-classroom-backend.md) |

Exercises stay identical markdown. Only the connection chapter and the SQL
dialect differ.

## Evidence

Verified 2026-08-21 on a real Free Edition workspace, dbt Core 1.12 with
`dbt-databricks`: exercise 2 (`samples.tpch` → `stg_customer`, `stg_orders` →
`customer_stats`) builds in 14 s including a cold warehouse. The built-in
`samples.tpch` holds ~500k customers, so thresholds that return zero rows
against the tiny local sample behave as intended.

## Consequences

- Source data lives in a different place per backend, so sources are declared
  per target rather than once.
- Databricks Free Edition is a free product and its limits move under us: one
  workspace, one 2X-Small warehouse, no SLA, inactive accounts deleted. A
  returning learner may have to start over.
- pgAdmin on a forwarded port is the least polished part of the Postgres setup.
  SQLTools covers most query needs; dropping the pgAdmin container is an option.
