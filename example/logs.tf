# Supporting Infrastructure - Real logging resources for testing
# This infrastructure is created from remote GitHub modules to provide
# realistic logging dependencies for the primary module example.
# 
# Available module outputs (reference directly in main.tf):
# - module.logging_bucket.bucket_name
# - module.logging_bucket.bucket_arn
#
# Example usage in main.tf:
#   logging_target_bucket = module.logging_bucket.bucket_name

module "logging_bucket" {
  source = "git::https://github.com/islamelkadi/terraform-aws-s3.git"

  namespace   = var.namespace
  environment = var.environment
  name        = "example-logs"
  region      = var.region

  # Direct reference to kms.tf module output
  kms_key_arn = module.kms_key.key_arn

  # Lifecycle policy for log retention
  enable_lifecycle_policy = true
  glacier_transition_days = 90

  # Security control override for logging bucket (no recursive logging)
  security_control_overrides = {
    disable_logging_requirement = true
    justification               = "This is a logging bucket - recursive logging not required"
  }

  tags = {
    Purpose = "example-supporting-infrastructure"
  }
}
