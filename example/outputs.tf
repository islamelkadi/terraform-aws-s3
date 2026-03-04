# S3 Example Outputs

# Basic Bucket Outputs
output "basic_bucket_name" {
  description = "Name of the basic S3 bucket"
  value       = module.basic_bucket.bucket_name
}

output "basic_bucket_arn" {
  description = "ARN of the basic S3 bucket"
  value       = module.basic_bucket.bucket_arn
}

output "basic_bucket_domain_name" {
  description = "Domain name of the basic S3 bucket"
  value       = module.basic_bucket.bucket_domain_name
}

# Production Bucket Outputs
output "production_bucket_name" {
  description = "Name of the production S3 bucket"
  value       = module.production_bucket.bucket_name
}

output "production_bucket_arn" {
  description = "ARN of the production S3 bucket"
  value       = module.production_bucket.bucket_arn
}

output "production_bucket_domain_name" {
  description = "Domain name of the production S3 bucket"
  value       = module.production_bucket.bucket_domain_name
}

# Archive Bucket Outputs
output "archive_bucket_name" {
  description = "Name of the archive S3 bucket"
  value       = module.archive_bucket.bucket_name
}

output "archive_bucket_arn" {
  description = "ARN of the archive S3 bucket"
  value       = module.archive_bucket.bucket_arn
}

output "archive_bucket_domain_name" {
  description = "Domain name of the archive S3 bucket"
  value       = module.archive_bucket.bucket_domain_name
}
