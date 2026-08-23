# Snowsight sign-in only; dbt uses a programmatic access token.
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
  for_each = var.participants

  length      = 16
  min_upper   = 2
  min_lower   = 2
  min_numeric = 2
  special     = false # easy to type; length carries the entropy
}

resource "aws_cognito_user" "participant" {
  for_each = var.participants

  user_pool_id = aws_cognito_user_pool.participants.id
  username     = each.key

  # Permanent: a forced change on first use would derail the start of the day.
  password = random_password.participant[each.key].result

  # These addresses route logins; they are not mailboxes.
  message_action = "SUPPRESS"

  attributes = {
    email          = each.value
    email_verified = true
  }
}
