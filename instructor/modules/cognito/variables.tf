variable "participants" {
  type        = map(string)
  description = "Course-scoped address per participant, resolved by the participants module. Deriving it here too is how the two drift apart."

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

variable "snowflake_callback_urls" {
  type        = list(string)
  description = "OAuth callback URLs. Cognito matches redirect_uri exactly and answers a miss with redirect_mismatch, so register every hostname Snowflake might use."
}

variable "access_token_validity_hours" {
  type        = number
  default     = 12
  description = "Snowsight session lifetime."
}
