# Example input variables
# Copy this file and customize for your environment

namespace   = "example"
environment = "dev"
region      = "us-east-1"

# Bucket configuration
bucket_name  = "data-storage"
project_name = "example-project"

# KMS encryption - replace with your actual KMS key ARN
kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"

# Versioning and lifecycle
enable_versioning       = true
enable_lifecycle_policy = true
glacier_transition_days = 90

# Logging - replace with your actual logging bucket name
logging_bucket_name = "my-logging-bucket"

# Access control - replace with your actual IAM role ARNs
allowed_principals = [
  "arn:aws:iam::123456789012:role/my-lambda-role"
]

