# S3 Bucket Examples

This example demonstrates various S3 bucket configurations with security control overrides.

## Structure

This example includes:
- **main.tf**: Primary module examples (3 bucket configurations)
- **kms.tf**: Supporting KMS key infrastructure
- **logs.tf**: Supporting logging bucket infrastructure
- **iam.tf**: Supporting IAM role infrastructure

## Examples Included

### 1. Basic S3 Bucket
Minimal configuration with KMS encryption and lifecycle policies. Logging disabled for dev environments.

### 2. Production S3 Bucket
Full compliance configuration with versioning, logging, lifecycle policies, and IAM access controls.

### 3. Archive Bucket
Optimized for long-term storage with aggressive lifecycle policies (Glacier transition after 30 days).

## Supporting Infrastructure

The supporting infrastructure files create real AWS resources from remote GitHub modules:
- **KMS Key**: Provides encryption for all buckets
- **Logging Bucket**: Stores access logs for the production bucket
- **IAM Role**: Demonstrates bucket access policies

## Supporting Infrastructure

The supporting infrastructure files create real AWS resources from remote GitHub modules:
- **KMS Key**: Provides encryption for all buckets
- **Logging Bucket**: Stores access logs for the production bucket
- **IAM Role**: Demonstrates bucket access policies

## Usage

```bash
terraform init
terraform plan
terraform apply
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->