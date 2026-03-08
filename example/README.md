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
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.34 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_archive_bucket"></a> [archive\_bucket](#module\_archive\_bucket) | ../ | n/a |
| <a name="module_basic_bucket"></a> [basic\_bucket](#module\_basic\_bucket) | ../ | n/a |
| <a name="module_iam_role"></a> [iam\_role](#module\_iam\_role) | git::https://github.com/islamelkadi/terraform-aws-iam.git//modules/role | v1.0.0 |
| <a name="module_kms_key"></a> [kms\_key](#module\_kms\_key) | git::https://github.com/islamelkadi/terraform-aws-kms.git | v1.0.0 |
| <a name="module_logging_bucket"></a> [logging\_bucket](#module\_logging\_bucket) | git::https://github.com/islamelkadi/terraform-aws-s3.git | v1.0.0 |
| <a name="module_production_bucket"></a> [production\_bucket](#module\_production\_bucket) | ../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Base name for S3 buckets | `string` | `"data-storage"` | no |
| <a name="input_enable_lifecycle_policy"></a> [enable\_lifecycle\_policy](#input\_enable\_lifecycle\_policy) | Enable lifecycle policy for transitioning to Glacier | `bool` | `true` | no |
| <a name="input_enable_versioning"></a> [enable\_versioning](#input\_enable\_versioning) | Enable S3 bucket versioning | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | `"dev"` | no |
| <a name="input_glacier_transition_days"></a> [glacier\_transition\_days](#input\_glacier\_transition\_days) | Number of days before transitioning objects to Glacier | `number` | `90` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace (organization/team name) | `string` | `"example"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name for tagging | `string` | `"example-project"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region for resources | `string` | `"us-east-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_archive_bucket_arn"></a> [archive\_bucket\_arn](#output\_archive\_bucket\_arn) | ARN of the archive S3 bucket |
| <a name="output_archive_bucket_domain_name"></a> [archive\_bucket\_domain\_name](#output\_archive\_bucket\_domain\_name) | Domain name of the archive S3 bucket |
| <a name="output_archive_bucket_name"></a> [archive\_bucket\_name](#output\_archive\_bucket\_name) | Name of the archive S3 bucket |
| <a name="output_basic_bucket_arn"></a> [basic\_bucket\_arn](#output\_basic\_bucket\_arn) | ARN of the basic S3 bucket |
| <a name="output_basic_bucket_domain_name"></a> [basic\_bucket\_domain\_name](#output\_basic\_bucket\_domain\_name) | Domain name of the basic S3 bucket |
| <a name="output_basic_bucket_name"></a> [basic\_bucket\_name](#output\_basic\_bucket\_name) | Name of the basic S3 bucket |
| <a name="output_production_bucket_arn"></a> [production\_bucket\_arn](#output\_production\_bucket\_arn) | ARN of the production S3 bucket |
| <a name="output_production_bucket_domain_name"></a> [production\_bucket\_domain\_name](#output\_production\_bucket\_domain\_name) | Domain name of the production S3 bucket |
| <a name="output_production_bucket_name"></a> [production\_bucket\_name](#output\_production\_bucket\_name) | Name of the production S3 bucket |
<!-- END_TF_DOCS -->