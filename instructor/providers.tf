provider "snowflake" {
  organization_name = var.organization_name
  account_name      = var.account_name
  user              = var.admin_user
  role              = var.admin_role

  # Credentials come from the environment so they never land in a .tfvars file:
  #   export SNOWFLAKE_AUTHENTICATOR=SNOWFLAKE_JWT
  #   export SNOWFLAKE_PRIVATE_KEY="$(cat ~/.snowflake/<account>_tf.p8)"
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}
