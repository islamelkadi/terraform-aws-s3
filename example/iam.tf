# Supporting Infrastructure - Real IAM resources for testing
# This infrastructure is created from remote GitHub modules to provide
# realistic IAM dependencies for the primary module example.
# 
# Available module outputs (reference directly in main.tf):
# - module.iam_role.role_arn
# - module.iam_role.role_name
#
# Example usage in main.tf:
#   allowed_principals = [module.iam_role.role_arn]

module "iam_role" {
  source = "git::https://github.com/islamelkadi/terraform-aws-iam.git//modules/role?ref=v1.0.0"

  namespace   = var.namespace
  environment = var.environment
  name        = "example-role"
  region      = var.region

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]

  tags = {
    Purpose = "example-supporting-infrastructure"
  }
}
