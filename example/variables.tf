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
