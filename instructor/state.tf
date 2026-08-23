# Shared with the other academy setups in datamindedacademy/instructor_setups,
# which keep their state under the same states/ prefix.
#
# The profile is hardcoded because a backend block cannot take variables. Pass
# -backend-config="profile=..." to tofu init if yours differs.
terraform {
  backend "s3" {
    bucket  = "dataminded-academy-shared-infrastructure"
    key     = "states/academy-dbt.tfstate"
    region  = "eu-west-1"
    profile = "instructor"
    encrypt = true

    # S3-native locking; no DynamoDB table to maintain.
    use_lockfile = true
  }
}
