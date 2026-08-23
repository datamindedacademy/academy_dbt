# Programmatic access tokens: what participants put in their IDE and in dbt.
#
# A PAT is presented in place of the password, so it works with anything that
# takes a password -- the dbt adapter, the Snowflake VS Code extension, SnowSQL.
# It cannot sign in to Snowsight; that is what the Cognito federation is for.

# Snowflake refuses to let a TYPE=PERSON user authenticate with a PAT unless a
# network policy applies to them. Participants connect from wherever their
# codespace happens to run, so the only workable list is everything. The real
# containment is per-participant roles and schemas, not IP filtering.
resource "snowflake_network_policy" "participants" {
  name            = "${var.prefix}_PARTICIPANTS"
  allowed_ip_list = ["0.0.0.0/0"]
  comment         = "Permissive by necessity: PAT authentication requires a network policy and participants connect from arbitrary codespace IPs."
}

resource "snowflake_user_programmatic_access_token" "participant" {
  for_each = local.participants

  user = snowflake_user.participant[each.key].name
  name = "DBT"

  # Pins the token to the participant's own role, so a leaked token cannot be
  # used to assume anything else the user might later be granted.
  role_restriction = snowflake_account_role.participant[each.key].name

  days_to_expiry = var.token_days_to_expiry
  comment        = "dbt and IDE access for ${each.key}."

  # role_restriction is only valid once the role is actually granted.
  depends_on = [snowflake_grant_account_role.participant_to_user]
}
