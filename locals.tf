# Local values for naming and tagging

locals {
  # Use metadata module for standardized naming
  bucket_name_base = module.metadata.resource_prefix

  # Construct bucket name with optional attributes
  bucket_name = length(var.attributes) > 0 ? "${local.bucket_name_base}-${join(var.delimiter, var.attributes)}" : local.bucket_name_base

  # Merge tags with defaults
  tags = merge(
    var.tags,
    module.metadata.security_tags,
    {
      Name   = local.bucket_name
      Module = "terraform-aws-s3"
    }
  )
}
