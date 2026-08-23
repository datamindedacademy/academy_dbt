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
  }
}
