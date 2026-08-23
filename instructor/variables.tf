variable "organization_name" {
  type        = string
  description = "Your Snowflake organization name. SELECT CURRENT_ORGANIZATION_NAME();"
}

variable "account_name" {
  type        = string
  description = "Your Snowflake account name. SELECT CURRENT_ACCOUNT_NAME();"
}

variable "admin_user" {
  type        = string
  description = "The user Terraform authenticates as. Needs a role that can create users, roles, databases and warehouses (ACCOUNTADMIN, or USERADMIN + SYSADMIN)."
}

variable "admin_role" {
  type        = string
  default     = "ACCOUNTADMIN"
  description = "Role Terraform assumes. ACCOUNTADMIN is the simplest; narrow it if your account policy requires."
}

variable "prefix" {
  type        = string
  default     = "ACADEMY_DBT"
  description = "Prefix for every Snowflake object created for this course."
}

variable "participant_email_domain" {
  type        = string
  default     = ""
  description = "Domain for course-scoped addresses, e.g. academy.example.com."
}

variable "access_token_validity_hours" {
  type        = number
  default     = 12
  description = "Lifetime of the Cognito access token participants give to dbt."
}

variable "aws_region" {
  type        = string
  default     = "eu-west-1"
  description = "AWS region for the Cognito user pool."
}

variable "aws_profile" {
  type        = string
  default     = null
  description = "AWS CLI profile Terraform uses for Cognito."
}


variable "warehouse_size" {
  type        = string
  default     = "XSMALL"
  description = "Size of the shared warehouse."
}


variable "snowsight_login_label" {
  type        = string
  default     = "Academy login"
  description = "Text on the sign-in button on the Snowflake login page. Keep it short; the integration name is used when this is unset, and those are long."

  validation {
    condition     = length(var.snowsight_login_label) <= 30
    error_message = "snowsight_login_label should be at most 30 characters so it fits the button."
  }
}

variable "extra_oidc_callback_urls" {
  type        = list(string)
  default     = []
  description = "Additional OAuth callback URLs to register on the Cognito client, e.g. the account-locator hostname. The org-account form is always included."
}

