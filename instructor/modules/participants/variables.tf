variable "participants" {
  type        = set(string)
  description = <<-EOT
    Names of the course participants, as written in participants.yaml.
    Each name becomes one Snowflake user, one role and one schema. Names are
    upper-cased and non-alphanumeric characters are replaced by underscores, so
    "grace.hopper" and "Grace Hopper" both become GRACE_HOPPER.
  EOT

  validation {
    condition     = length(var.participants) > 0
    error_message = "participants must not be empty: add at least one name to participants.yaml."
  }

  validation {
    condition = length(var.participants) == length(distinct([
      for name in var.participants : upper(replace(name, "/[^a-zA-Z0-9]/", "_"))
    ]))
    error_message = "Two participants normalise to the same Snowflake identifier. Names differing only in case or punctuation (e.g. \"grace.hopper\" and \"Grace Hopper\") collide; make them distinct."
  }
}

variable "account_identifier" {
  type        = string
  description = "Account identifier in \"myorg-myaccount\" form. Only used to render the credential handout."
}

variable "prefix" {
  type        = string
  default     = "ACADEMY_DBT"
  description = "Prefix for every object this module creates, so several courses can share one Snowflake account."
}

variable "participant_email_domain" {
  type        = string
  description = "Domain for course-scoped addresses, e.g. academy.example.com. Must match what the cognito module assigns."

  validation {
    condition     = !startswith(var.participant_email_domain, "@")
    error_message = "participant_email_domain is a bare domain; leave off the leading @."
  }
}

variable "warehouse_size" {
  type        = string
  default     = "XSMALL"
  description = "Size of the shared warehouse. XSMALL is plenty for TPC-H SF1."
}


variable "token_days_to_expiry" {
  type        = number
  default     = 7
  description = "Lifetime of each participant's programmatic access token. Long enough to cover the course; it cannot be changed after creation, only rotated."

  validation {
    condition     = var.token_days_to_expiry >= 1
    error_message = "token_days_to_expiry must be at least 1."
  }
}
