# Security Controls Validations
# Enforces security standards based on metadata module security controls
# Supports selective overrides with documented justification

locals {
  # Use security controls if provided, otherwise use permissive defaults
  security_controls = var.security_controls != null ? var.security_controls : {
    encryption = {
      require_kms_customer_managed  = false
      require_encryption_at_rest    = false
      require_encryption_in_transit = false
      enable_kms_key_rotation       = false
    }
    logging = {
      require_cloudwatch_logs = false
      min_log_retention_days  = 1
      require_access_logging  = false
      require_flow_logs       = false
    }
    data_protection = {
      require_versioning         = false
      require_mfa_delete         = false
      require_automated_backups  = false
      block_public_access        = false
      require_lifecycle_policies = false
    }
  }

  # Apply overrides to security controls
  kms_encryption_required   = local.security_controls.encryption.require_kms_customer_managed && !var.security_control_overrides.disable_kms_requirement
  versioning_required       = local.security_controls.data_protection.require_versioning && !var.security_control_overrides.disable_versioning_requirement
  access_logging_required   = local.security_controls.logging.require_access_logging && !var.security_control_overrides.disable_logging_requirement
  lifecycle_policy_required = local.security_controls.data_protection.require_lifecycle_policies && !var.security_control_overrides.disable_lifecycle_requirement
  # Validation results
  kms_validation_passed        = !local.kms_encryption_required || var.kms_key_arn != null
  versioning_validation_passed = !local.versioning_required || var.enable_versioning
  logging_validation_passed    = !local.access_logging_required || (var.enable_logging && var.logging_target_bucket != null)
  lifecycle_validation_passed  = !local.lifecycle_policy_required || var.enable_lifecycle_policy

  # Audit trail for overrides
  has_overrides = (
    var.security_control_overrides.disable_kms_requirement ||
    var.security_control_overrides.disable_versioning_requirement ||
    var.security_control_overrides.disable_logging_requirement ||
    var.security_control_overrides.disable_lifecycle_requirement ||
    var.security_control_overrides.disable_public_access_block
  )

  justification_provided = var.security_control_overrides.justification != ""
  override_audit_passed  = !local.has_overrides || local.justification_provided
}

# Security Controls Check Block
check "security_controls_compliance" {
  assert {
    condition     = local.kms_validation_passed
    error_message = "Security control violation: KMS customer-managed key is required but kms_key_arn is not provided. Set security_control_overrides.disable_kms_requirement=true with justification if this is intentional."
  }

  assert {
    condition     = local.versioning_validation_passed
    error_message = "Security control violation: S3 versioning is required but enable_versioning is false. Set security_control_overrides.disable_versioning_requirement=true with justification if this is intentional."
  }

  assert {
    condition     = local.logging_validation_passed
    error_message = "Security control violation: S3 access logging is required but not configured. Set enable_logging=true and provide logging_target_bucket, or set security_control_overrides.disable_logging_requirement=true with justification."
  }

  assert {
    condition     = local.lifecycle_validation_passed
    error_message = "Security control violation: Lifecycle policy is required but enable_lifecycle_policy is false. Set security_control_overrides.disable_lifecycle_requirement=true with justification if this is intentional."
  }

  assert {
    condition     = local.override_audit_passed
    error_message = "Security control overrides detected but no justification provided. Please document the business reason in security_control_overrides.justification for audit compliance."
  }
}
