# S3 Bucket Module Variables

# Metadata variables for consistent naming
variable "namespace" {
  description = "Namespace (organization/team name)"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod"
  }
}

variable "name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "attributes" {
  description = "Additional attributes for naming"
  type        = list(string)
  default     = []
}

variable "delimiter" {
  description = "Delimiter to use between name components"
  type        = string
  default     = "-"
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

# S3 specific variables
variable "kms_key_arn" {
  description = "ARN of KMS key for bucket encryption"
  type        = string
}

variable "enable_versioning" {
  description = "Enable versioning for the bucket"
  type        = bool
  default     = true
}

variable "enable_lifecycle_policy" {
  description = "Enable lifecycle policy for the bucket"
  type        = bool
  default     = true
}

variable "glacier_transition_days" {
  description = "Number of days after which objects transition to Glacier storage class"
  type        = number
  default     = 90

  validation {
    condition     = var.glacier_transition_days >= 30
    error_message = "Glacier transition must be at least 30 days"
  }
}

variable "noncurrent_version_expiration_days" {
  description = "Number of days after which noncurrent versions expire. Set to 0 to disable"
  type        = number
  default     = 0

  validation {
    condition     = var.noncurrent_version_expiration_days >= 0
    error_message = "Noncurrent version expiration days must be non-negative"
  }
}

variable "enable_logging" {
  description = "Enable access logging for the bucket"
  type        = bool
  default     = false
}

variable "logging_target_bucket" {
  description = "Target bucket for access logs. Required if enable_logging is true"
  type        = string
  default     = null
}

variable "logging_target_prefix" {
  description = "Prefix for access log objects. Defaults to bucket name"
  type        = string
  default     = null
}

variable "bucket_policy" {
  description = "Custom bucket policy JSON. If not provided, a default policy will be created"
  type        = string
  default     = null
}

variable "allowed_principals" {
  description = "List of IAM role/user ARNs allowed to access the bucket"
  type        = list(string)
  default     = []
}

variable "allowed_actions" {
  description = "List of S3 actions allowed for the principals"
  type        = list(string)
  default = [
    "s3:GetObject",
    "s3:PutObject",
    "s3:DeleteObject",
    "s3:ListBucket"
  ]
}

variable "cloudfront_distribution_arn" {
  description = "CloudFront distribution ARN for bucket policy with OAC. When provided, grants read access to CloudFront using Origin Access Control (recommended over OAI)"
  type        = string
  default     = null
}

variable "region" {
  description = "AWS region where resources will be created"
  type        = string
}

# Security Controls
variable "security_controls" {
  description = "Security controls configuration from metadata module. Used to enforce security standards"
  type = object({
    encryption = object({
      require_kms_customer_managed  = bool
      require_encryption_at_rest    = bool
      require_encryption_in_transit = bool
      enable_kms_key_rotation       = bool
    })
    logging = object({
      require_cloudwatch_logs = bool
      min_log_retention_days  = number
      require_access_logging  = bool
      require_flow_logs       = bool
    })
    data_protection = object({
      require_versioning         = bool
      require_mfa_delete         = bool
      require_automated_backups  = bool
      block_public_access        = bool
      require_lifecycle_policies = bool
    })
  })
  default = null
}

# Security Control Overrides
variable "security_control_overrides" {
  description = <<-EOT
    Override specific security controls for this S3 bucket.
    Only use when there's a documented business justification.
    
    Example use cases:
    - disable_versioning_requirement: Static website hosting (content version-controlled in Git)
    - disable_kms_requirement: Public website assets (no sensitive data)
    - disable_logging_requirement: Low-value buckets (cost optimization)
    
    IMPORTANT: Document the reason in the 'justification' field for audit purposes.
  EOT

  type = object({
    disable_kms_requirement        = optional(bool, false)
    disable_versioning_requirement = optional(bool, false)
    disable_logging_requirement    = optional(bool, false)
    disable_lifecycle_requirement  = optional(bool, false)
    disable_public_access_block    = optional(bool, false)

    # Audit trail - document why controls are disabled
    justification = optional(string, "")
  })

  default = {
    disable_kms_requirement        = false
    disable_versioning_requirement = false
    disable_logging_requirement    = false
    disable_lifecycle_requirement  = false
    disable_public_access_block    = false
    justification                  = ""
  }
}


