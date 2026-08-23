# Instructor setup

**Only needed to teach the course, not to take it.** Anyone with a Snowflake
account can do the exercises on their own — see
[`docs/setup_instructions.md`](../docs/setup_instructions.md).

This provisions a whole class from one apply. Each participant gets:

| | For | Why |
| --- | --- | --- |
| a username | both | their Snowflake `LOGIN_NAME`, also their Cognito username |
| an access token | dbt, VS Code | a PAT needs no MFA and no browser redirect |
| a password | Snowsight | PATs cannot sign in to the web UI |

Neither credential involves MFA enrolment, which is the point: Snowflake requires
a second factor for password sign-ins, and a classroom cannot start the day in
Duo.

Also created: a shared warehouse and database, a schema and role per participant,
and a `0.0.0.0/0` network policy — Snowflake refuses PAT authentication without
one, and participants connect from arbitrary codespace IPs. Isolation comes from
the per-participant roles, not IP filtering.

Source data is the `SNOWFLAKE_SAMPLE_DATA.TPCH_SF1` share: the same TPC-H tables
as the other backends, nothing to load, no storage cost.

## Usage

Prerequisites: [OpenTofu](https://opentofu.org/) ≥ 1.6, `jq`, AWS credentials and
a Snowflake account.

### Authenticating

You need ACCOUNTADMIN. Pick whichever fits; all three set the same provider.

**Password + MFA — nothing to set up.** If you are already an account admin with
a password, this needs no key and no new Snowflake objects:

```sh
export SNOWFLAKE_AUTHENTICATOR=USERNAMEPASSWORDMFA
export SNOWFLAKE_PASSWORD='...'
```

You approve one MFA push per session; the connector caches the token on macOS
and Windows.

**Key pair — no prompts, good for repeated applies.** Register a key on your own
user:

```sh
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:4096 -out ~/.snowflake/tf.p8
openssl rsa -pubout -in ~/.snowflake/tf.p8 | grep -v -- ----- | tr -d '
'
```

```sql
ALTER USER <you> SET RSA_PUBLIC_KEY = '<that output>';
```

```sh
export SNOWFLAKE_AUTHENTICATOR=SNOWFLAKE_JWT
export SNOWFLAKE_PRIVATE_KEY="$(cat ~/.snowflake/tf.p8)"
```

**Profile — no environment variables.** Set `snowflake_profile` in
`terraform.tfvars` and put the same values in `~/.snowflake/config`, `chmod
0600`. Note this is the provider's own file: it is not `connections.toml`, and
`private_key` must be the PEM inline, not a path.

```toml
[summerschool]
organization_name = 'MYORG'
account_name      = 'SUMMERSCHOOL'
user              = 'TERRAFORM'
role              = 'ACCOUNTADMIN'
authenticator     = 'SNOWFLAKE_JWT'
private_key       = """<contents of tf.p8>"""
```

No Snowflake account yet? Create one as ORGADMIN with `CREATE ACCOUNT`; the
region is permanent.

```sh
cp terraform.tfvars.example terraform.tfvars   # org, account, profile name
cp participants.yaml.example participants.yaml # the class list

tofu init && tofu apply
./scripts/render_credentials.sh
```

That writes one folder per participant under `out/`, each with a `.env` and a
`README.txt`. Hand them out, then delete the folder. Participants copy the `.env`
into their codespace and run `./create_profiles.sh`; nothing expires during the
course.

Tearing down:

```sh
tofu destroy && rm -rf out
```

Removing a name from `participants.yaml` and re-applying does the same for one
person.

## Traps

Each of these fails with an error pointing somewhere else.

- **PATs authenticate against `LOGIN_NAME`**, not the user's name.
  `ACADEMY_DBT_ADA_LOVELACE` gives "Programmatic access token is invalid";
  `ada.lovelace` works.
- **User mapping is `cognito:username` → `LOGIN_NAME`.** The obvious
  `email` → `EMAIL_ADDRESS` resolves nobody even when the addresses match
  exactly, and fails as `INCORRECT_USERNAME_PASSWORD`.
- **Register every callback URL Snowflake advertises.** It answers on three
  hostnames and picks among them — in testing it chose the *locator* one. Cognito
  compares `redirect_uri` byte for byte and answers a miss with
  `redirect_mismatch`. `OIDC_REDIRECT_URIS` is read-only, so read the real list
  with `DESC SECURITY INTEGRATION` and put the extras in
  `extra_oidc_callback_urls`.
- **Set `OIDC_LOGIN_PAGE_LABEL`**, or the sign-in button shows the integration
  name.
- **Fresh accounts sometimes lack the sample data.** The plan stops with
  instructions; the fix is
  `CREATE DATABASE snowflake_sample_data FROM SHARE sfc_samples.sample_data;`
- **Cognito schema attributes can be added but never removed.** Changing them
  replaces the pool, which changes the issuer and forces the OIDC integration to
  be recreated.

Snowflake reports nearly every federated failure as
`INCORRECT_USERNAME_PASSWORD`. Decode the UUID from the error:

```sql
SELECT SYSTEM$GET_LOGIN_FAILURE_DETAILS('<uuid>');
SELECT * FROM TABLE(SNOWFLAKE.INFORMATION_SCHEMA.LOGIN_HISTORY(
  TIME_RANGE_START => DATEADD(minute,-15,CURRENT_TIMESTAMP())));
```

A null user with `first_authentication_factor = OIDC_ID_TOKEN` means the token
arrived fine and the mapping is wrong.

## Secrets

Tokens, passwords and the OIDC client secret live in state in cleartext. State is
in S3 (`dataminded-academy-shared-infrastructure`, encrypted, same bucket as the
other academy setups), so treat read access to it as access to the class.

The provider has no OIDC integration resource (checked at v2.20.0), so
`federation.tf` creates that one with `snowflake_execute`.
