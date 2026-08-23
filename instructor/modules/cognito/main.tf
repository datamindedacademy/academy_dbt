locals {
  participants = {
    for name in var.participants : name => {
      username = name
      email    = "${name}@${var.email_domain}"
    }
  }
}

# Identities for Snowsight sign-in only. dbt and IDEs authenticate to Snowflake
# with a programmatic access token instead, so nothing here needs to shape an
# access token -- Snowflake's OIDC flow reads the ID token, which already
# carries the aud and email claims it matches on.
resource "aws_cognito_user_pool" "participants" {
  name = "${var.prefix}-participants"

  auto_verified_attributes = ["email"]

  password_policy {
    minimum_length    = 12
    require_lowercase = true
    require_uppercase = true
    require_numbers   = true
    require_symbols   = false
  }

  admin_create_user_config {
    allow_admin_create_user_only = true
  }
}

resource "random_password" "participant" {
  for_each = local.participants

  length      = 16
  min_upper   = 2
  min_lower   = 2
  min_numeric = 2
  special     = false # keep handouts easy to type; length carries the entropy
}

resource "aws_cognito_user" "participant" {
  for_each = local.participants

  user_pool_id = aws_cognito_user_pool.participants.id
  username     = each.value.username

  # Permanent, not temporary: a forced password change on first use would derail
  # the start of a one-day course.
  password = random_password.participant[each.key].result

  # No welcome email. These addresses are routing identifiers, not mailboxes.
  message_action = "SUPPRESS"

  attributes = {
    email          = each.value.email
    email_verified = true
  }
}
