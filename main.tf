# S3 Bucket Module
# Creates AWS S3 bucket with encryption, versioning, lifecycle policies, and logging

resource "aws_s3_bucket" "this" {
  bucket = local.bucket_name

  tags = local.tags
}

# Enable versioning
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

# Enable server-side encryption with KMS
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
    bucket_key_enabled = true
  }
}

# Configure lifecycle policies
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count  = var.enable_lifecycle_policy ? 1 : 0
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "transition-to-glacier"
    status = "Enabled"

    # Apply to all objects
    filter {}

    transition {
      days          = var.glacier_transition_days
      storage_class = "GLACIER"
    }

    noncurrent_version_transition {
      noncurrent_days = var.glacier_transition_days
      storage_class   = "GLACIER"
    }
  }

  # Optional expiration for old versions
  dynamic "rule" {
    for_each = var.noncurrent_version_expiration_days > 0 ? [1] : []
    content {
      id     = "expire-old-versions"
      status = "Enabled"

      # Apply to all objects
      filter {}

      noncurrent_version_expiration {
        noncurrent_days = var.noncurrent_version_expiration_days
      }
    }
  }
}

# Enable access logging
resource "aws_s3_bucket_logging" "this" {
  count  = var.enable_logging ? 1 : 0
  bucket = aws_s3_bucket.this.id

  target_bucket = var.logging_target_bucket
  target_prefix = var.logging_target_prefix != null ? var.logging_target_prefix : "${local.bucket_name}/"
}

# Block public access
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket policy for least privilege access
resource "aws_s3_bucket_policy" "this" {
  count  = var.bucket_policy != null || length(var.allowed_principals) > 0 || var.cloudfront_distribution_arn != null ? 1 : 0
  bucket = aws_s3_bucket.this.id

  policy = var.bucket_policy != null ? var.bucket_policy : data.aws_iam_policy_document.default[0].json
}

# Default bucket policy if none provided
data "aws_iam_policy_document" "default" {
  count = var.bucket_policy == null && (length(var.allowed_principals) > 0 || var.cloudfront_distribution_arn != null) ? 1 : 0

  # Enforce SSL/TLS for all requests
  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:*"]

    resources = [
      aws_s3_bucket.this.arn,
      "${aws_s3_bucket.this.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  # Allow CloudFront OAC to access bucket (for static website hosting)
  # OAC is AWS's recommended approach over legacy OAI
  dynamic "statement" {
    for_each = var.cloudfront_distribution_arn != null ? [1] : []
    content {
      sid    = "AllowCloudFrontServicePrincipal"
      effect = "Allow"

      principals {
        type        = "Service"
        identifiers = ["cloudfront.amazonaws.com"]
      }

      actions = ["s3:GetObject"]

      resources = ["${aws_s3_bucket.this.arn}/*"]

      condition {
        test     = "StringEquals"
        variable = "AWS:SourceArn"
        values   = [var.cloudfront_distribution_arn]
      }
    }
  }

  # Allow specified principals to access bucket
  dynamic "statement" {
    for_each = length(var.allowed_principals) > 0 ? [1] : []
    content {
      sid    = "AllowPrincipalAccess"
      effect = "Allow"

      principals {
        type        = "AWS"
        identifiers = var.allowed_principals
      }

      actions = var.allowed_actions

      resources = [
        aws_s3_bucket.this.arn,
        "${aws_s3_bucket.this.arn}/*"
      ]
    }
  }
}

# Data sources removed - using metadata module instead
