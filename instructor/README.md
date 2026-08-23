# Instructor setup: Snowflake environments for participants

**You only need this to teach the course, not to take it.**

Anyone with a Snowflake account can do the exercises on their own: fill in the
`SNOWFLAKE_*` values in `.env` and use an access token or a key pair. See
[`docs/setup_instructions.md`](../docs/setup_instructions.md).

This directory is for the other case: an educator running a classroom who wants
*n* students on a real warehouse without any of them creating a Snowflake
account. Each student gets three things from one `tofu apply`:

| | For | Why not something simpler |
| --- | --- | --- |
| a username | both | the Snowflake `LOGIN_NAME`, which is also their Cognito username |
| an access token | dbt, the VS Code extension | a PAT authenticates without MFA and without a browser redirect |
| a password | the Snowsight web UI | PATs cannot sign in to Snowsight, so the UI goes through Cognito |

Neither credential involves MFA enrolment, which is the point: Snowflake now
requires a second factor for password sign-ins, and a classroom cannot spend the
first hour of the day enrolling in Duo.

It replaces the Snowflake module that used to live in
[`instructor_setups/capstone-project/modules/snowflake`](https://github.com/datamindedacademy/instructor_setups),
updated for the current provider and for Snowflake's MFA rules.

## What it creates

For a class of *n* participants:

| Object | Count | Name |
| --- | --- | --- |
| Warehouse | 1 | `ACADEMY_DBT_WH` |
| Database | 1 | `ACADEMY_DBT_DB` |
| Schema | *n* | `ACADEMY_DBT_DB.<PARTICIPANT>` |
| User | *n* | `ACADEMY_DBT_<PARTICIPANT>`, login name `<participant>` |
| Access token | *n* | one PAT per user, for dbt and the IDE |
| Network policy | 1 | `0.0.0.0/0`, required for PAT authentication |
| Role | *n* + 1 | `ACADEMY_DBT_<PARTICIPANT>`, `ACADEMY_DBT_STUDENT` |

Every participant role inherits `ACADEMY_DBT_STUDENT`, which carries usage on the
warehouse and database plus read access to `SNOWFLAKE_SAMPLE_DATA`. On top of
that each role has full rights on its own schema and nothing on anyone else's.

Source data is the `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1` share that ships with every
Snowflake account — the same TPC-H tables the Postgres and Databricks backends
of this course use, so nothing needs loading. Being a share, it also costs you no
storage.

Freshly created accounts occasionally lack it. The module checks, and fails the
plan with instructions rather than an opaque grant error; the fix is one
statement as `ACCOUNTADMIN`:

```sql
CREATE DATABASE snowflake_sample_data FROM SHARE sfc_samples.sample_data;
```

## Why two credentials

A programmatic access token covers dbt and the VS Code extension: no MFA, no
browser, no identity provider. It cannot sign in to Snowsight, though — PATs are
programmatic only — so the web UI goes through Cognito instead.

Plain passwords are not an option for either. Snowflake's [deprecation of
single-factor password sign-ins](https://docs.snowflake.com/en/user-guide/security-mfa-rollout)
requires MFA for every password sign-in by a `TYPE=PERSON` user regardless of
authentication policy, and `MINS_TO_BYPASS_MFA` relaxes the MFA challenge rather
than the enrolment requirement. A classroom cannot spend its first hour in Duo.

## How it fits together

- **dbt and the VS Code extension** use a programmatic access token, handed out
  in `.env`. A PAT is presented in place of a password, so it needs no
  authenticator, no browser and no identity provider — which is what makes it
  work in a codespace, where the usual `externalbrowser` flow cannot complete its
  localhost callback.
- **Snowsight** uses an `OIDC` security integration against Cognito, because a
  PAT cannot sign in to the web UI.

Snowflake refuses PAT authentication for a `TYPE=PERSON` user unless a network
policy applies to them. Participants connect from wherever their codespace runs,
so `modules/participants/tokens.tf` attaches a `0.0.0.0/0` policy. The real
containment is the per-participant role and schema, not IP filtering.

### Traps, recorded so they cost time only once

- **PATs authenticate against `LOGIN_NAME`, not the user's name.** Passing
  `ACADEMY_DBT_ADA_LOVELACE` fails with "Programmatic access token is invalid";
  `ada.lovelace` works. The handout uses `LOGIN_NAME`, which doubles as the
  Cognito username.
- **User mapping is `cognito:username` → `LOGIN_NAME`.** The obvious-looking
  `email` → `EMAIL_ADDRESS` did not resolve a user, despite the ID token
  carrying the right email, the Snowflake user's `EMAIL` matching exactly, and no
  duplicate. It fails as a generic `INCORRECT_USERNAME_PASSWORD`.
- **Register every callback URL Snowflake advertises.** It answers on three
  hostnames and picks among them; Cognito compares `redirect_uri` byte for byte
  and answers a miss with `redirect_mismatch`. `OIDC_REDIRECT_URIS` is read-only,
  so you cannot pin it — read the real list with
  `DESC SECURITY INTEGRATION <name>` and register them all.
- **Set `OIDC_LOGIN_PAGE_LABEL`.** Unset, the button on the login page shows the
  integration name.
- **Use the account URL, not `app.snowflake.com`.** The classic login page at
  `https://<org>-<account>.snowflakecomputing.com` renders the SSO button
  reliably.

### Diagnosing a failed sign-in

Snowflake reports nearly every federated failure as
`INCORRECT_USERNAME_PASSWORD`. The error carries a UUID; decode it as an admin:

```sql
SELECT SYSTEM$GET_LOGIN_FAILURE_DETAILS('<uuid>');
```

`clientType` tells you which form was used and `username` whether a user was
resolved at all — a null user with `first_authentication_factor = OIDC_ID_TOKEN`
means the token arrived fine and the *mapping* is wrong. For a live view:

```sql
SELECT * FROM TABLE(SNOWFLAKE.INFORMATION_SCHEMA.LOGIN_HISTORY(
  TIME_RANGE_START => DATEADD(minute,-15,CURRENT_TIMESTAMP())));
```

## Bootstrapping a course account

Skip this if you already have an account to run the course in. Otherwise
`scripts/bootstrap_account.sh` generates the SQL that creates one, plus the RSA
key pair Terraform will authenticate with. It prints; it never connects.

```sh
./scripts/bootstrap_account.sh \
  --account summerschool \
  --edition STANDARD \
  --admin-name grace_hopper \
  --email grace.hopper@example.com
```

Read the output before running it. It comes in two blocks: `CREATE ACCOUNT`,
which needs ORGADMIN in your organization's admin account, and the in-account
setup, which needs ACCOUNTADMIN in the new account.

Three things worth knowing:

- **Region is permanent.** Name and edition can be changed afterwards with
  `ALTER ACCOUNT`; region cannot. With no `--region`, the SQL omits the clause
  and Snowflake places the account in the same region as the org admin account
  you run it from — usually what you want, and no irreversible guess. Pass
  `--region aws_eu_central_1` (or similar) only if you need it elsewhere.
- **`STANDARD` is enough.** Nothing here needs Enterprise. The one thing to watch
  is Time Travel: Standard allows 0–1 days, and the module sets
  `data_retention_time_in_days = 1` on participant schemas, which fits.
- **`MUST_CHANGE_PASSWORD` defaults to `FALSE`** in Snowflake, not `TRUE`. The
  generated SQL sets it explicitly so the behaviour is visible.

The script creates a `terraform` service user with key-pair auth, so applies
never hit an MFA prompt. Your own admin user is a `PERSON` user and will be asked
to enrol in MFA on first Snowsight sign-in, which is the right outcome for an
account admin.

## Usage

Prerequisites: [OpenTofu](https://opentofu.org/) (or Terraform) ≥ 1.6, `jq`, and
a Snowflake user with `ACCOUNTADMIN` (or `USERADMIN` + `SYSADMIN`).

```sh
cd instructor
cp terraform.tfvars.example terraform.tfvars   # your org, account, admin user
cp participants.yaml.example participants.yaml # the class list
```

`participants.yaml` is a plain list of names:

```yaml
- grace.hopper
- ada.lovelace
```

Names are upper-cased and stripped of punctuation, so `grace.hopper` becomes the
user `ACADEMY_DBT_GRACE_HOPPER` and the schema `GRACE_HOPPER`.

Authenticate Terraform through the environment so nothing lands in a file:

```sh
export SNOWFLAKE_AUTHENTICATOR=SNOWFLAKE_JWT
export SNOWFLAKE_PRIVATE_KEY="$(cat ~/.snowflake/<account>_tf.p8)"
```

Then:

```sh
tofu init
tofu plan
tofu apply
./scripts/render_credentials.sh
```

That writes one folder per participant under `out/`, each with a `.env`, a dbt
profile snippet and a `README.txt`. Hand them out and delete the folder.

### Tearing down

```sh
tofu destroy
rm -rf out
```

This drops every participant schema and everything in it. Removing a single name
from `participants.yaml` and re-applying does the same for that one person.

## What participants do

They receive the folder `render_credentials.sh` produced, copy its `.env` to the
repository root, and run:

```sh
./create_profiles.sh
dbt debug --target snowflake
```

`create_profiles.sh` writes the `snowflake` target and
`~/.snowflake/connections.toml` only when those `SNOWFLAKE_*` values are present,
so participants on Postgres or Databricks are unaffected. Nothing expires during
the course.

## A note on secrets

Participant passwords, private keys and the OIDC client secret are stored in
cleartext in `terraform.tfstate`, which `.gitignore` keeps out of git. That is
acceptable for an environment torn down the same week; if these outlive a course,
move state to a backend with encryption and access control.
