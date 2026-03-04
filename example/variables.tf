# S3 Example Variables

variable "region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "namespace" {
  description = "Namespace (organization/team name)"
  type        = string
  default     = "example"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "bucket_name" {
  description = "Base name for S3 buckets"
  type        = string
  default     = "data-storage"
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
  default     = "example-project"
}

variable "kms_key_arn" {
  description = "ARN of KMS key for S3 bucket encryption (replace with your actual KMS key)"
  type        = string
}

variable "enable_versioning" {
  description = "Enable S3 bucket versioning"
  type        = bool
  default     = true
}

variable "enable_lifecycle_policy" {
  description = "Enable lifecycle policy for transitioning to Glacier"
  type        = bool
  default     = true
}

variable "glacier_transition_days" {
  description = "Number of days before transitioning objects to Glacier"
  type        = number
  default     = 90
}

variable "logging_bucket_name" {
  description = "Name of S3 bucket for access logs (replace with your actual logging bucket)"
  type        = string
  default     = "my-logging-bucket"
}

variable "allowed_principals" {
  description = "List of IAM principal ARNs allowed to access the bucket (replace with your actual IAM roles)"
  type        = list(string)
}
