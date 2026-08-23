# Credentials come from a Snowflake CLI profile in ~/.snowflake/config (0600),
# so nothing secret lives in this repo or the environment:
#
#   [summerschool]
#   organization_name = 'DATAMINDED'
#   account_name      = 'SUMMERSCHOOL'
#   user              = 'TERRAFORM'
#   role              = 'ACCOUNTADMIN'
#   authenticator     = 'SNOWFLAKE_JWT'
#   private_key       = '''<PEM>'''
#
# The account is also named explicitly because it builds the OIDC callback URLs.
# Explicit values win over the profile, so the two cannot disagree.
provider "snowflake" {
  profile           = var.snowflake_profile
  organization_name = var.organization_name
  account_name      = var.account_name
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}
