variable "organization_name" {
  type        = string
  description = "Snowflake organization name. SELECT CURRENT_ORGANIZATION_NAME();"
}

variable "account_name" {
  type        = string
  description = "Snowflake account name. SELECT CURRENT_ACCOUNT_NAME();"
}

variable "admin_user" {
  type        = string
  description = "User Terraform authenticates as; needs ACCOUNTADMIN."
}

variable "admin_role" {
  type        = string
  default     = "ACCOUNTADMIN"
  description = "Role Terraform assumes."
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
  description = "Snowsight session lifetime."
}

variable "aws_region" {
  type        = string
  default     = "eu-west-1"
  description = "Region for the Cognito user pool."
}

variable "aws_profile" {
  type        = string
  default     = null
  description = "AWS CLI profile Terraform uses for Cognito."
}


variable "warehouse_size" {
  type        = string
  default     = "XSMALL"
  description = "Size of the shared warehouse. XSMALL handles 15 participants on TPC-H SF1."
}


variable "snowsight_login_label" {
  type        = string
  default     = "Academy login"
  description = "Text on the sign-in button. Unset, Snowflake shows the integration name."

}

variable "extra_oidc_callback_urls" {
  type        = list(string)
  default     = []
  description = "Extra callback URLs to register. Snowflake answers on several hostnames and picks among them; find the list with DESC SECURITY INTEGRATION."
}

