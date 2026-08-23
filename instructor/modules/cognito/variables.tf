variable "participants" {
  type        = set(string)
  description = "Participant names, as written in participants.yaml. Each becomes a Cognito user who can sign in to Snowsight."

  validation {
    condition     = length(var.participants) > 0
    error_message = "participants must not be empty."
  }
}

variable "prefix" {
  type        = string
  default     = "academy-dbt"
  description = "Prefix for the AWS resources this module creates."
}

variable "email_domain" {
  type        = string
  description = "Domain for course-scoped addresses, e.g. academy.example.com. Snowflake matches the OIDC token's email against the user's EMAIL, and course attendees come from too many employers for their real domains to route on. The address never has to receive mail."
}

variable "snowflake_callback_urls" {
  type        = list(string)
  description = <<-EOT
    OAuth callback URLs, each https://<account_url>/oauth2/oidc/callback.

    Register every URL Snowflake might send: it answers on several hostnames and
    Cognito matches redirect_uri exactly, answering a miss with
    `redirect_mismatch`. OIDC_REDIRECT_URIS is read-only, so read the real list
    with DESC SECURITY INTEGRATION.
  EOT
}

variable "access_token_validity_hours" {
  type        = number
  default     = 12
  description = "Session lifetime for Snowsight sign-ins."

  validation {
    condition     = var.access_token_validity_hours >= 1 && var.access_token_validity_hours <= 24
    error_message = "access_token_validity_hours must be between 1 and 24."
  }
}
