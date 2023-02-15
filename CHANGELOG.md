# Changelog

All notable changes to this project will be documented in this file.

### [0.0.7](https://github.com/rundeck-io/terraform-aws-ec2-rundeck/compare/v0.0.6...v0.0.7) (2023-02-15)

### Features

* Add support to choose EC2 spot instance via the `create_spot_instance` variable. Note this now defaults to `false`.
* Add `ec2_instance_id` to module's output.
* Add `security_group_id` to module's output.
* Add module variable validations.
* Bumped terraform `required_version` to 0.14.

### [0.0.6](https://github.com/rundeck-io/terraform-aws-ec2-rundeck/compare/v0.0.5...v0.0.6) (2023-02-12) 

### Bug Fixes

* A second `terraform apply` results in no changes.

### Features

* Add support for EC2 instance profile via the `aws_iam_policy_arns` variable.
* Add support for custom EC2 root volume size via the `root_volume_size` variable.
* Add support for encrypting EC2 root volume via the `root_encrypted` variable.
