# Terraform AWS S3 Module

A reusable Terraform module for creating AWS S3 buckets with AWS Security Hub compliance (FSBP, CIS, NIST 800-53, NIST 800-171, PCI DSS), KMS encryption, versioning, lifecycle policies, and flexible security control overrides.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Security Controls](#security-controls)
- [Features](#features)
- [Usage Examples](#usage-examples)
- [Requirements](#requirements)
- [Inputs](#inputs)
- [Outputs](#outputs)
- [Examples](#examples)

---

## Prerequisites

This module is designed for macOS. The following must already be installed on your machine:
- Python 3 and pip
- [Kiro](https://kiro.dev) and Kiro CLI
- [Homebrew](https://brew.sh)

To install the remaining development tools, run:

```bash
make bootstrap
```

This will install/upgrade: tfenv, Terraform (via tfenv), tflint, terraform-docs, checkov, and pre-commit.

## Security Controls

This module implements AWS Security Hub compliance with an extensible override system.

### Available Security Control Overrides

| Override Flag | Description | Common Justification |
|--------------|-------------|---------------------|
| `disable_kms_requirement` | Allows AWS-managed encryption | "Public website assets, no sensitive data" |
| `disable_versioning_requirement` | Disables versioning | "Static website, content version-controlled in Git" |
| `disable_logging_requirement` | Disables access logging | "Low-value bucket, cost optimization" |
| `disable_lifecycle_requirement` | Disables lifecycle policies | "Short-lived data, manual cleanup" |
| `disable_public_access_block` | Allows public access | "Public website hosting, reviewed by security team" |

### Security Best Practices

**Production Buckets:**
- Use KMS customer-managed keys
- Enable versioning for data protection
- Enable access logging
- Configure lifecycle policies
- Block all public access (unless explicitly needed)

**Development Buckets:**
- KMS encryption still recommended
- Versioning optional for cost savings
- Access logging optional

## Features

- S3 bucket with KMS encryption
- Versioning for data protection
- Access logging support
- Lifecycle policies for cost optimization
- Public access blocking by default
- Bucket policy management
- Security controls integration

## Usage Examples

### Basic Example

```hcl
module "s3_bucket" {
  source = "github.com/islamelkadi/terraform-aws-s3?ref=v1.0.0"
  
  namespace   = "example"
  environment = "prod"
  name        = "data"
  region      = "us-east-1"
  
  kms_key_arn = module.kms.key_arn
  
  tags = {
    Project = "CorporateActions"
  }
}
```

### Production Bucket with Security Controls

```hcl
module "s3_bucket" {
  source = "github.com/islamelkadi/terraform-aws-s3?ref=v1.0.0"
  
  security_controls = module.metadata.security_controls
  
  namespace   = "example"
  environment = "prod"
  name        = "corporate-actions-data"
  region      = "us-east-1"
  
  kms_key_arn = module.kms.key_arn
  
  # Versioning enabled
  enable_versioning = true
  
  # Access logging
  enable_logging        = true
  logging_target_bucket = module.logs_bucket.bucket_name
  logging_target_prefix = "corporate-actions-data/"
  
  # Lifecycle policy
  enable_lifecycle_policy             = true
  glacier_transition_days             = 90
  noncurrent_version_expiration_days  = 30
  
  # Bucket policy
  allowed_principals = [
    module.lambda.role_arn,
    module.step_function.role_arn
  ]
  
  tags = {
    Project    = "CorporateActions"
    DataClass  = "Confidential"
    Compliance = "PCI-DSS"
  }
}
```

### Static Website Bucket with Overrides

```hcl
module "website_bucket" {
  source = "github.com/islamelkadi/terraform-aws-s3?ref=v1.0.0"
  
  security_controls = module.metadata.security_controls
  
  security_control_overrides = {
    disable_versioning_requirement = true
    disable_kms_requirement        = true
    disable_public_access_block    = true
    justification = "Public static website hosting. Content is version-controlled in Git. No sensitive data. Public access required for CloudFront distribution. Reviewed and approved by security team."
  }
  
  namespace   = "example"
  environment = "prod"
  name        = "public-website"
  region      = "us-east-1"
  
  # Use AWS-managed encryption for public content
  kms_key_arn = null
  
  # Versioning not needed (Git is source of truth)
  enable_versioning = false
  
  # No lifecycle policy needed
  enable_lifecycle_policy = false
  
  tags = {
    Project = "PublicWebsite"
    Purpose = "StaticContent"
  }
}
```

### CloudFront Static Website with OAC

```hcl
# S3 bucket with CloudFront OAC integration
module "website_bucket" {
  depends_on = [module.cdn]
  
  source = "github.com/islamelkadi/terraform-aws-s3?ref=v1.0.0"
  
  namespace   = "example"
  environment = "prod"
  name        = "website"
  region      = "us-east-1"
  
  kms_key_arn = module.kms.key_arn
  
  # CloudFront OAC integration - automatically creates bucket policy
  cloudfront_distribution_arn = module.cdn.distribution_arn
  
  tags = {
    Project = "Website"
    Purpose = "StaticContent"
  }
}

# CloudFront distribution with OAC (recommended over legacy OAI)
module "cdn" {
  source = "github.com/islamelkadi/terraform-aws-cloudfront?ref=v1.0.0"
  
  origin_domain_name        = module.website_bucket.bucket_regional_domain_name
  use_origin_access_control = true  # Use OAC (recommended)
  
  # ... other CloudFront configuration
}
```

## Environment-Based Security Controls

Security controls are automatically applied based on the environment through the [terraform-aws-metadata](https://github.com/islamelkadi/terraform-aws-metadata?tab=readme-ov-file#security-profiles){:target="_blank"} module's security profiles:

| Control | Dev | Staging | Prod |
|---------|-----|---------|------|
| KMS customer-managed keys | Optional | Required | Required |
| Versioning | Optional | Required | Required |
| Access logging | Optional | Required | Required |
| Public access block | Recommended | Required | Required |
| Lifecycle policies | Optional | Recommended | Required |

For full details on security profiles and how controls vary by environment, see the <a href="https://github.com/islamelkadi/terraform-aws-metadata?tab=readme-ov-file#security-profiles" target="_blank">Security Profiles</a> documentation.

## MCP Servers

This module includes two [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) servers configured in `.kiro/settings/mcp.json` for use with Kiro:

| Server | Package | Description |
|--------|---------|-------------|
| `aws-docs` | `awslabs.aws-documentation-mcp-server@latest` | Provides access to AWS documentation for contextual lookups of service features, API references, and best practices. |
| `terraform` | `awslabs.terraform-mcp-server@latest` | Enables Terraform operations (init, validate, plan, fmt, tflint) directly from the IDE with auto-approved commands for common workflows. |

Both servers run via `uvx` and require no additional installation beyond the [bootstrap](#prerequisites) step.

<!-- BEGIN_TF_DOCS -->


## Usage

```hcl
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

```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.34 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.34 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_metadata"></a> [metadata](#module\_metadata) | github.com/islamelkadi/terraform-aws-metadata | v1.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_logging.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_iam_policy_document.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_actions"></a> [allowed\_actions](#input\_allowed\_actions) | List of S3 actions allowed for the principals | `list(string)` | <pre>[<br/>  "s3:GetObject",<br/>  "s3:PutObject",<br/>  "s3:DeleteObject",<br/>  "s3:ListBucket"<br/>]</pre> | no |
| <a name="input_allowed_principals"></a> [allowed\_principals](#input\_allowed\_principals) | List of IAM role/user ARNs allowed to access the bucket | `list(string)` | `[]` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | Additional attributes for naming | `list(string)` | `[]` | no |
| <a name="input_bucket_policy"></a> [bucket\_policy](#input\_bucket\_policy) | Custom bucket policy JSON. If not provided, a default policy will be created | `string` | `null` | no |
| <a name="input_cloudfront_distribution_arn"></a> [cloudfront\_distribution\_arn](#input\_cloudfront\_distribution\_arn) | CloudFront distribution ARN for bucket policy with OAC. When provided, grants read access to CloudFront using Origin Access Control (recommended over OAI) | `string` | `null` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to use between name components | `string` | `"-"` | no |
| <a name="input_enable_lifecycle_policy"></a> [enable\_lifecycle\_policy](#input\_enable\_lifecycle\_policy) | Enable lifecycle policy for the bucket | `bool` | `true` | no |
| <a name="input_enable_logging"></a> [enable\_logging](#input\_enable\_logging) | Enable access logging for the bucket | `bool` | `false` | no |
| <a name="input_enable_versioning"></a> [enable\_versioning](#input\_enable\_versioning) | Enable versioning for the bucket | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (dev, staging, prod) | `string` | n/a | yes |
| <a name="input_glacier_transition_days"></a> [glacier\_transition\_days](#input\_glacier\_transition\_days) | Number of days after which objects transition to Glacier storage class | `number` | `90` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | ARN of KMS key for bucket encryption | `string` | n/a | yes |
| <a name="input_logging_target_bucket"></a> [logging\_target\_bucket](#input\_logging\_target\_bucket) | Target bucket for access logs. Required if enable\_logging is true | `string` | `null` | no |
| <a name="input_logging_target_prefix"></a> [logging\_target\_prefix](#input\_logging\_target\_prefix) | Prefix for access log objects. Defaults to bucket name | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the S3 bucket | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace (organization/team name) | `string` | n/a | yes |
| <a name="input_noncurrent_version_expiration_days"></a> [noncurrent\_version\_expiration\_days](#input\_noncurrent\_version\_expiration\_days) | Number of days after which noncurrent versions expire. Set to 0 to disable | `number` | `0` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region where resources will be created | `string` | n/a | yes |
| <a name="input_security_control_overrides"></a> [security\_control\_overrides](#input\_security\_control\_overrides) | Override specific security controls for this S3 bucket.<br/>Only use when there's a documented business justification.<br/><br/>Example use cases:<br/>- disable\_versioning\_requirement: Static website hosting (content version-controlled in Git)<br/>- disable\_kms\_requirement: Public website assets (no sensitive data)<br/>- disable\_logging\_requirement: Low-value buckets (cost optimization)<br/><br/>IMPORTANT: Document the reason in the 'justification' field for audit purposes. | <pre>object({<br/>    disable_kms_requirement        = optional(bool, false)<br/>    disable_versioning_requirement = optional(bool, false)<br/>    disable_logging_requirement    = optional(bool, false)<br/>    disable_lifecycle_requirement  = optional(bool, false)<br/>    disable_public_access_block    = optional(bool, false)<br/><br/>    # Audit trail - document why controls are disabled<br/>    justification = optional(string, "")<br/>  })</pre> | <pre>{<br/>  "disable_kms_requirement": false,<br/>  "disable_lifecycle_requirement": false,<br/>  "disable_logging_requirement": false,<br/>  "disable_public_access_block": false,<br/>  "disable_versioning_requirement": false,<br/>  "justification": ""<br/>}</pre> | no |
| <a name="input_security_controls"></a> [security\_controls](#input\_security\_controls) | Security controls configuration from metadata module. Used to enforce security standards | <pre>object({<br/>    encryption = object({<br/>      require_kms_customer_managed  = bool<br/>      require_encryption_at_rest    = bool<br/>      require_encryption_in_transit = bool<br/>      enable_kms_key_rotation       = bool<br/>    })<br/>    logging = object({<br/>      require_cloudwatch_logs = bool<br/>      min_log_retention_days  = number<br/>      require_access_logging  = bool<br/>      require_flow_logs       = bool<br/>    })<br/>    data_protection = object({<br/>      require_versioning         = bool<br/>      require_mfa_delete         = bool<br/>      require_automated_backups  = bool<br/>      block_public_access        = bool<br/>      require_lifecycle_policies = bool<br/>    })<br/>  })</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | S3 bucket ARN |
| <a name="output_bucket_domain_name"></a> [bucket\_domain\_name](#output\_bucket\_domain\_name) | S3 bucket domain name |
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | S3 bucket ID (same as bucket name) |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | S3 bucket name |
| <a name="output_bucket_region"></a> [bucket\_region](#output\_bucket\_region) | S3 bucket region |
| <a name="output_bucket_regional_domain_name"></a> [bucket\_regional\_domain\_name](#output\_bucket\_regional\_domain\_name) | S3 bucket regional domain name |
| <a name="output_tags"></a> [tags](#output\_tags) | Tags applied to the S3 bucket |

## Example

See [example/](example/) for a complete working example with all features.

## License

MIT Licensed. See [LICENSE](LICENSE) for full details.
<!-- END_TF_DOCS -->

## Examples

See [example/](example/) for a complete working example with all features.

