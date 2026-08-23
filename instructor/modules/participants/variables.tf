variable "participants" {
  type        = set(string)
  description = "Participant names from participants.yaml. Each becomes a user, role and schema."

  validation {
    condition     = length(var.participants) > 0
    error_message = "participants must not be empty: add at least one name to participants.yaml."
  }

  validation {
    condition = length(var.participants) == length(distinct([
      for name in var.participants : upper(replace(name, "/[^a-zA-Z0-9]/", "_"))
    ]))
    error_message = "Two participants normalise to the same Snowflake identifier. Names differing only in case or punctuation collide; make them distinct."
  }
}

variable "account_identifier" {
  type        = string
  description = "Account identifier in myorg-myaccount form, for the credential handout."
}

variable "prefix" {
  type        = string
  default     = "ACADEMY_DBT"
  description = "Prefix for every object this module creates."
}

variable "participant_email_domain" {
  type        = string
  description = "Domain for course-scoped addresses, e.g. academy.example.com."
}

variable "warehouse_size" {
  type        = string
  default     = "XSMALL"
  description = "Size of the shared warehouse. XSMALL handles 15 participants on TPC-H SF1."
}
