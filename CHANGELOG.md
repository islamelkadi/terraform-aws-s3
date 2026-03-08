## [1.0.2](https://github.com/islamelkadi/terraform-aws-s3/compare/v1.0.1...v1.0.2) (2026-03-08)


### Bug Fixes

* add CKV_TF_1 suppression for external module metadata ([0494029](https://github.com/islamelkadi/terraform-aws-s3/commit/0494029ce3309f8288289040fb1fb3d8cbc2d9f6))
* add skip-path for .external_modules in Checkov config ([3666107](https://github.com/islamelkadi/terraform-aws-s3/commit/3666107dd6d6b7572f6d06b3e433683559806104))
* address Checkov security findings ([2457089](https://github.com/islamelkadi/terraform-aws-s3/commit/2457089ace40e04545547a5a3f8826001a4b3e7a))
* correct .checkov.yaml format to use simple list instead of id/comment dict ([4026e68](https://github.com/islamelkadi/terraform-aws-s3/commit/4026e68f1ce33b65d599a9d0f7eb2be7f531bf7b))
* remove skip-path from .checkov.yaml, rely on workflow-level skip_path ([c6ec34b](https://github.com/islamelkadi/terraform-aws-s3/commit/c6ec34b17b4b2e4b566ac54d692f38f25b8e7da5))
* update workflow path reference to terraform-security.yaml ([12ab042](https://github.com/islamelkadi/terraform-aws-s3/commit/12ab042153a63cfac88f8fb25aee97b8c8d92a8e))

## [1.0.1](https://github.com/islamelkadi/terraform-aws-s3/compare/v1.0.0...v1.0.1) (2026-03-08)


### Code Refactoring

* enhance examples with real infrastructure and improve code quality ([35bf152](https://github.com/islamelkadi/terraform-aws-s3/commit/35bf152f8f3690eb69d10394de221012b3d666b9))

## 1.0.0 (2026-03-07)


### ⚠ BREAKING CHANGES

* First publish - S3 Terraform module

### Features

* First publish - S3 Terraform module ([4fa3403](https://github.com/islamelkadi/terraform-aws-s3/commit/4fa340395b5c3ace7a550943cdf8382cab8dc9e2))
