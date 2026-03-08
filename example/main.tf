# Primary Module Example - This demonstrates the terraform-aws-s3 module
# Supporting infrastructure (KMS, IAM, logging bucket) is defined in separate files
# to keep this example focused on the module's core functionality.
#
# S3 Bucket Examples
# Demonstrates various S3 bucket configurations with security control overrides

# ============================================================================
# Example 1: Basic S3 Bucket (Minimal Configuration)
# Override: Logging disabled for cost optimization in dev
# ============================================================================

module "basic_bucket" {
  source = "../"

  namespace   = var.namespace
  environment = var.environment
  name        = var.bucket_name
  region      = var.region

  # Direct reference to kms.tf module output
  kms_key_arn = module.kms_key.key_arn

  # Versioning enabled for data protection
  enable_versioning = var.enable_versioning

  # Lifecycle policy - transition to Glacier after 90 days
  enable_lifecycle_policy = var.enable_lifecycle_policy
  glacier_transition_days = var.glacier_transition_days

  # Security Control Override: Logging disabled for dev
  security_control_overrides = {
    disable_logging_requirement = true
    justification               = "Development environment - access logging disabled for cost optimization. Production will enable logging to separate audit bucket."
  }

  tags = {
    Project = var.project_name
    Example = "basic"
  }
}

# ============================================================================
# Example 2: Production S3 Bucket with Full Compliance
# All security controls enforced (Versioning, Logging, Lifecycle)
# ============================================================================

module "production_bucket" {
  source = "../"

  namespace   = var.namespace
  environment = "prod"
  name        = "${var.bucket_name}-prod"
  region      = var.region

  # Direct reference to kms.tf module output
  kms_key_arn = module.kms_key.key_arn

  # Versioning enabled for compliance
  enable_versioning = true

  # Lifecycle policy - transition to Glacier after 90 days
  enable_lifecycle_policy = true
  glacier_transition_days = 90

  # Noncurrent version expiration after 1 year
  noncurrent_version_expiration_days = 365

  # Direct reference to logs.tf module output
  enable_logging        = true
  logging_target_bucket = module.logging_bucket.bucket_name
  logging_target_prefix = "production-bucket/"

  # Direct reference to iam.tf module output
  allowed_principals = [module.iam_role.role_arn]

  allowed_actions = [
    "s3:GetObject",
    "s3:PutObject"
  ]

  tags = {
    Environment = "Production"
    Compliance  = "FullyCompliant"
    Project     = var.project_name
    Example     = "production"
  }
}

# ============================================================================
# Example 3: Archive Bucket (Long-term Storage)
# Optimized for infrequent access with aggressive lifecycle policies
# ============================================================================

module "archive_bucket" {
  source = "../"

  namespace   = var.namespace
  environment = var.environment
  name        = "${var.bucket_name}-archive"
  region      = var.region

  # Direct reference to kms.tf module output
  kms_key_arn = module.kms_key.key_arn

  # Versioning enabled for audit trail
  enable_versioning = true

  # Aggressive lifecycle policy - transition to Glacier after 30 days
  enable_lifecycle_policy = true
  glacier_transition_days = 30

  # Noncurrent versions expire after 90 days
  noncurrent_version_expiration_days = 90

  # Security Control Override: Logging disabled for dev
  security_control_overrides = {
    disable_logging_requirement = true
    justification               = "Development environment - archive bucket for testing. Production will enable logging."
  }

  tags = {
    Project = var.project_name
    Purpose = "archive"
    Example = "archive"
  }
}

