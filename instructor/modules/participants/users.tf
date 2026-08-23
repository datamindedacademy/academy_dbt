# One TYPE=PERSON user per participant, with no password and no key: the only
# way in is Cognito. LOGIN_NAME must equal the Cognito username and EMAIL the
# Cognito email, because that is what the two Snowflake integrations match on.

resource "snowflake_user" "participant" {
  for_each = local.participants

  name         = "${var.prefix}_${each.value}"
  login_name   = each.key
  email        = local.participant_emails[each.key]
  display_name = local.participant_display_names[each.key]
  comment      = "Data Minded dbt course participant ${each.key}."

  # Required for the programmatic access tokens in tokens.tf.
  network_policy = snowflake_network_policy.participants.name

  default_warehouse = snowflake_warehouse.class.name
  default_role      = snowflake_account_role.participant[each.key].name
  default_namespace = "${snowflake_database.class.name}.${snowflake_schema.participant[each.key].name}"
}
