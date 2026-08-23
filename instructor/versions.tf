terraform {
  required_version = ">= 1.6"

  required_providers {
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = "~> 2.19"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }

  # State holds participant passwords and private keys in cleartext. Local state
  # is fine for a course that is torn down the same week, as long as the file
  # stays out of git (see .gitignore). Move it to a backend with encryption and
  # access control if you keep these environments around.
}
