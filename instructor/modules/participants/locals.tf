locals {
  # Snowflake identifiers are upper-case and cannot contain punctuation unless
  # quoted:  "grace.hopper" -> GRACE_HOPPER
  participants = {
    for name in var.participants :
    name => upper(replace(name, "/[^a-zA-Z0-9]/", "_"))
  }

  database_name  = "${var.prefix}_DB"
  warehouse_name = "${var.prefix}_WH"
  shared_role    = "${var.prefix}_STUDENT"

  participant_emails = {
    for name, id in local.participants : name => "${name}@${var.participant_email_domain}"
  }

  # Snowsight shows this instead of the object name: "Grace Hopper" rather than
  # ACADEMY_DBT_GRACE_HOPPER.
  participant_display_names = {
    for name, id in local.participants :
    name => title(replace(replace(name, ".", " "), "_", " "))
  }
}
