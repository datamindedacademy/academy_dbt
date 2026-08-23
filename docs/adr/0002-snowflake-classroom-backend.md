# 2. Snowflake as a provisioned classroom backend

Date: 2026-08-23 · Status: accepted · Extends [ADR 1](0001-three-course-database-backends.md)

## Context

Databricks Free Edition puts every student in their own self-signed-up
workspace. That is fine on-site, but it gives the instructor no control: no
shared data, no way to fix a broken account, and one workspace per person.

Some cohorts also run on Snowflake because that is what the client uses, and a
Snowflake trial is not something fifteen people should each set up in the first
half hour of a course.

## Decision

Add Snowflake as a third backend, provisioned by the instructor. Terraform in
[`instructor/`](../../instructor/) creates the whole class from one apply: a
shared warehouse and database, a schema and role per participant, and two
credentials each.

Two credentials, because Snowflake requires MFA for password sign-in and a
classroom cannot start the day enrolling in Duo:

- a **programmatic access token** for dbt and the VS Code extension — no MFA,
  no browser redirect
- a **Cognito-federated password** for Snowsight, since a PAT cannot sign in to
  the web UI

Source data is the `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1` share that ships with the
account: the same TPC-H tables as the other backends, nothing to load, no
storage cost.

One XSMALL warehouse serves the class. Measured at 60 concurrent statements
(15 participants × dbt's 4 threads) against TPC-H SF1 it queued for 0.3 s and
averaged 0.1 s execution. Multi-cluster is the usual answer to concurrency, but
it needs Enterprise Edition.

Students on their own Snowflake account skip all of this and just fill in
`SNOWFLAKE_*` in `.env`.

## Consequences

- Snowflake is the only backend needing instructor work before a course. It is
  not a self-service path.
- Tokens, passwords and the OIDC client secret sit in Terraform state in
  cleartext. State is in S3, encrypted — treat read access to it as access to
  the class.
- The network policy is `0.0.0.0/0`: PAT authentication requires a policy and
  participants connect from arbitrary codespace IPs. Isolation comes from the
  per-participant roles, not IP filtering.
- PATs inherit the account policy default of 15 days, which outlives a course
  but not a semester.
- Federated login fails in ways Snowflake reports as
  `INCORRECT_USERNAME_PASSWORD` almost regardless of cause. The traps and how to
  decode them are in [`instructor/README.md`](../../instructor/README.md).
