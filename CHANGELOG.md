# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0](https://github.com/ironsmith-io/terraform-aws-ec2-rundeck/compare/v0.0.9...v1.0.0)  -  (2026-02-25)

### Breaking Changes

- Renamed `aws_subnet_id` to `subnet_id`; removed `aws_vpc_id` (derived from subnet)
- Renamed `ec2_instance_id` output to `instance_id`
- Renamed `rdeck_jvm_settings` to `rundeck_jvm_settings`
- Renamed all resource suffixes from `.rundeck` to `.this`
- Changed `ip_allow_ssh` and `ip_allow_https` type from `list(string)` to `set(string)` with empty default
- Removed `root_encrypted` variable (EBS encryption always enabled)
- Replaced `user_data.sh` with `cloud-init.yml` (#cloud-config YAML format)
- Bumped `required_version` from `>= 0.14` to `>= 1.5`
- Bumped `aws` provider from `>= 3.50.0` to `>= 5.0, < 7.0`

### Migration from v0.0.9

```hcl
# Before (v0.0.9)
module "rundeck" {
  source        = "ironsmith-io/ec2-rundeck/aws"
  version       = "0.0.9"
  aws_subnet_id = "subnet-xxx"
  key_pair_name = "my-key"
  ip_allow_https = ["0.0.0.0/0"]
}
output "id" { value = module.rundeck.ec2_instance_id }

# After (v1.0.0)
module "rundeck" {
  source         = "ironsmith-io/ec2-rundeck/aws"
  version        = "1.0.0"
  subnet_id      = "subnet-xxx"
  key_pair_name  = "my-key"
  ip_allow_https = ["0.0.0.0/0"]
}
output "id" { value = module.rundeck.instance_id }
```

### Added

- SSM Session Manager support (`enable_ssm`)
- SSH toggle (`enable_ssh`) for SSM-only deployments
- CloudWatch Logs, metrics, and operations dashboard (`enable_cloudwatch_logs`)
- Infrastructure alarms with SNS notifications (`enable_security_alarms`)
- Automated EBS snapshots via DLM (`enable_ebs_snapshots`)
- EC2 termination protection (`enable_termination_protection`)
- Rundeck admin password from SSM Parameter Store (`rundeck_admin_password_ssm_path`)
- Rundeck session timeout (`rundeck_session_timeout`) and plugin repository toggle
- `name`, `ami_id`, `user_data_extra`, `additional_security_group_ids`, `delete_volume_on_termination` variables
- `private_ip`, `ami_id`, `ami_name`, `ssh_command`, `iam_role_arn`, `cloudwatch_log_group_name`, `cloudwatch_dashboard_url`, `sns_topic_arn` outputs
- GovCloud/China region support via `data.aws_partition`
- `check` blocks for input validation (Terraform 1.5+)
- GitHub Actions CI (validate, unit tests, security scanning, lint)
- Terratest integration tests (`test/rundeck_test.go`)
- `terraform test` unit tests with mock providers (`tests/unit.tftest.hcl`)
- Three examples: `complete`, `minimal`, `ssm-only`
- `.envrc.example` for direnv-based environment setup

### Changed

- Single `aws_instance.this` resource (spot via dynamic `instance_market_options`)
- PostgreSQL 16 with SCRAM-SHA-256 authentication
- Let's Encrypt short-lived TLS certificates via acme.sh (self-signed fallback)
- Conditional IAM role/profile creation based on enabled features
- `key_pair_name` nullable (default: null) for SSM-only deployments

### Removed

- `aws_vpc_id` variable, `root_encrypted` variable
- `default-vpc` and `default-vpc-iam` examples
- `user_data.sh` (replaced by `cloud-init.yml`)

---

## [0.0.9](https://github.com/ironsmith-io/terraform-aws-ec2-rundeck/compare/v0.0.8...v0.0.9) (2024-02-06)

### Features

- Migrate to ironsmith-io organization

## [0.0.8](https://github.com/ironsmith-io/terraform-aws-ec2-rundeck/compare/v0.0.7...v0.0.8) (2023-02-23)

### Features

- Add support for custom Rundeck JVM settings via the `rdeck_jvm_settings` variable
- Add EC2 `public_ip` to module's output
- Add `default-vpc-iam` example
- Add support for tags via the `tags` variable

## [0.0.7](https://github.com/ironsmith-io/terraform-aws-ec2-rundeck/compare/v0.0.6...v0.0.7) (2023-02-15)

### Features

- Add support to choose EC2 spot instance via the `create_spot_instance` variable (defaults to `false`)
- Add `ec2_instance_id` to module's output
- Add `security_group_id` to module's output
- Add module variable validations
- Bump terraform `required_version` to 0.14

## [0.0.6](https://github.com/ironsmith-io/terraform-aws-ec2-rundeck/compare/v0.0.5...v0.0.6) (2023-02-12)

### Bug Fixes

- A second `terraform apply` results in no changes

### Features

- Add support for EC2 instance profile via the `aws_iam_policy_arns` variable
- Add support for custom EC2 root volume size via the `root_volume_size` variable
- Add support for encrypting EC2 root volume via the `root_encrypted` variable
