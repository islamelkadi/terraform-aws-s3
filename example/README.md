# Complete S3 Bucket Example

This example demonstrates a full-featured S3 bucket configuration with all security and lifecycle features enabled.

## Features Enabled

- KMS encryption (SSE-KMS) with customer-managed key
- Versioning enabled
- Lifecycle policy with Glacier transition after 90 days
- Noncurrent version expiration after 365 days
- Access logging to separate logging bucket
- Public access blocked
- SSL/TLS enforced
- Least privilege bucket policy with specific principals

## Architecture

This example creates two buckets:
1. **Logging Bucket**: Stores access logs from the main bucket
2. **Main Bucket**: Corporate actions raw feeds bucket with full features

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Outputs

- `bucket_name`: Name of the created S3 bucket
- `bucket_arn`: ARN of the created S3 bucket
- `logging_bucket_name`: Name of the logging bucket
