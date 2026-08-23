# Terraform needs an ACCOUNTADMIN. Credentials come from the environment or from
# a profile; nothing secret lives in this repo. See the README for the three
# ways to supply them.
provider "snowflake" {
  organization_name = var.organization_name
  account_name      = var.account_name
  user              = var.snowflake_user
  role              = var.snowflake_role
  profile           = var.snowflake_profile
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}
