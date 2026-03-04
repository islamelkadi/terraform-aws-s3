# S3 Bucket Examples
# Demonstrates various S3 bucket configurations with security control overrides

# ============================================================================
# Example 1: Basic S3 Bucket (Minimal Configuration)
# Uses fictitious KMS key ARN - replace with your actual KMS key
# Override: Logging disabled for cost optimization in dev
# ============================================================================

module "basic_bucket" {
  source = "../"

  namespace   = var.namespace
  environment = var.environment
  name        = var.bucket_name
  region      = var.region

  # KMS encryption - replace with your actual KMS key ARN
  kms_key_arn = var.kms_key_arn

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

  # KMS encryption - replace with your actual KMS key ARN
  kms_key_arn = var.kms_key_arn

  # Versioning enabled for compliance
  enable_versioning = true

  # Lifecycle policy - transition to Glacier after 90 days
  enable_lifecycle_policy = true
  glacier_transition_days = 90

  # Noncurrent version expiration after 1 year
  noncurrent_version_expiration_days = 365

  # Access logging enabled - replace with your actual logging bucket
  enable_logging        = true
  logging_target_bucket = var.logging_bucket_name
  logging_target_prefix = "production-bucket/"

  # Bucket policy - allow specific IAM roles
  # Replace with your actual IAM role ARNs
  allowed_principals = var.allowed_principals

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

  # KMS encryption - replace with your actual KMS key ARN
  kms_key_arn = var.kms_key_arn

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

