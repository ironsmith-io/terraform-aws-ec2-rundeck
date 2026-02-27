# Unit Tests - terraform test
# Run with: terraform test -filter=tests/unit.tftest.hcl
# These tests validate variable validation rules and feature flag combinations (no AWS calls)

# =============================================================================
# Mock Provider - prevents AWS API calls during unit tests
# =============================================================================

mock_provider "aws" {
  mock_data "aws_subnet" {
    defaults = {
      id                      = "subnet-mock12345"
      vpc_id                  = "vpc-mock12345"
      availability_zone       = "us-west-2a"
      cidr_block              = "10.0.1.0/24"
      map_public_ip_on_launch = true
    }
  }

  mock_data "aws_ami" {
    defaults = {
      id           = "ami-mock12345"
      name         = "Rocky-9-EC2-Base-9.5-20260201.0.x86_64"
      architecture = "x86_64"
    }
  }

  mock_data "aws_region" {
    defaults = {
      name = "us-west-2"
      id   = "us-west-2"
    }
  }

  mock_data "aws_partition" {
    defaults = {
      partition = "aws"
    }
  }
}

# =============================================================================
# Negative Tests - Variable Validation
# =============================================================================

run "rejects_invalid_subnet_id" {
  command = plan

  variables {
    subnet_id     = "invalid"
    key_pair_name = "test-key"
  }

  expect_failures = [var.subnet_id]
}

run "rejects_subnet_id_wrong_prefix" {
  command = plan

  variables {
    subnet_id     = "vpc-12345678"
    key_pair_name = "test-key"
  }

  expect_failures = [var.subnet_id]
}

run "rejects_subnet_id_too_short" {
  command = plan

  variables {
    subnet_id     = "subnet-1234"
    key_pair_name = "test-key"
  }

  expect_failures = [var.subnet_id]
}

run "rejects_invalid_cidr_ssh" {
  command = plan

  variables {
    subnet_id     = "subnet-12345678"
    key_pair_name = "test-key"
    ip_allow_ssh  = ["not-a-cidr"]
  }

  expect_failures = [var.ip_allow_ssh]
}

run "rejects_partial_cidr" {
  command = plan

  variables {
    subnet_id     = "subnet-12345678"
    key_pair_name = "test-key"
    ip_allow_ssh  = ["192.168.1.1"]
  }

  expect_failures = [var.ip_allow_ssh]
}

run "rejects_invalid_cidr_https" {
  command = plan

  variables {
    subnet_id      = "subnet-12345678"
    key_pair_name  = "test-key"
    ip_allow_https = ["invalid-cidr"]
  }

  expect_failures = [var.ip_allow_https]
}

run "rejects_invalid_instance_type" {
  command = plan

  variables {
    subnet_id     = "subnet-12345678"
    key_pair_name = "test-key"
    instance_type = "invalid-type"
  }

  expect_failures = [var.instance_type]
}

run "rejects_invalid_snapshot_time" {
  command = plan

  variables {
    subnet_id     = "subnet-12345678"
    key_pair_name = "test-key"
    snapshot_time = "25:00"
  }

  expect_failures = [var.snapshot_time]
}

run "rejects_snapshot_time_invalid_minutes" {
  command = plan

  variables {
    subnet_id     = "subnet-12345678"
    key_pair_name = "test-key"
    snapshot_time = "12:60"
  }

  expect_failures = [var.snapshot_time]
}

run "rejects_invalid_log_retention" {
  command = plan

  variables {
    subnet_id                     = "subnet-12345678"
    key_pair_name                 = "test-key"
    cloudwatch_log_retention_days = 999
  }

  expect_failures = [var.cloudwatch_log_retention_days]
}

run "rejects_too_many_iam_policies" {
  command = plan

  variables {
    subnet_id     = "subnet-12345678"
    key_pair_name = "test-key"
    aws_iam_policy_arns = [
      "arn:aws:iam::aws:policy/Policy1",
      "arn:aws:iam::aws:policy/Policy2",
      "arn:aws:iam::aws:policy/Policy3",
      "arn:aws:iam::aws:policy/Policy4",
      "arn:aws:iam::aws:policy/Policy5",
      "arn:aws:iam::aws:policy/Policy6",
      "arn:aws:iam::aws:policy/Policy7",
      "arn:aws:iam::aws:policy/Policy8",
      "arn:aws:iam::aws:policy/Policy9",
      "arn:aws:iam::aws:policy/Policy10",
      "arn:aws:iam::aws:policy/Policy11"
    ]
  }

  expect_failures = [var.aws_iam_policy_arns]
}

run "rejects_snapshot_retention_too_low" {
  command = plan

  variables {
    subnet_id               = "subnet-12345678"
    key_pair_name           = "test-key"
    snapshot_retention_days = 0
  }

  expect_failures = [var.snapshot_retention_days]
}

run "rejects_snapshot_retention_too_high" {
  command = plan

  variables {
    subnet_id               = "subnet-12345678"
    key_pair_name           = "test-key"
    snapshot_retention_days = 400
  }

  expect_failures = [var.snapshot_retention_days]
}

run "rejects_session_timeout_too_low" {
  command = plan

  variables {
    subnet_id               = "subnet-12345678"
    key_pair_name           = "test-key"
    rundeck_session_timeout = 4
  }

  expect_failures = [var.rundeck_session_timeout]
}

run "rejects_session_timeout_too_high" {
  command = plan

  variables {
    subnet_id               = "subnet-12345678"
    key_pair_name           = "test-key"
    rundeck_session_timeout = 500
  }

  expect_failures = [var.rundeck_session_timeout]
}

# =============================================================================
# Positive Tests - Valid Inputs
# =============================================================================

run "accepts_valid_minimal_config" {
  command = plan

  variables {
    subnet_id     = "subnet-12345678"
    key_pair_name = "test-key"
  }
}

run "accepts_valid_17char_subnet_id" {
  command = plan

  variables {
    subnet_id     = "subnet-0123456789abcdef0"
    key_pair_name = "test-key"
  }
}

run "accepts_multiple_valid_cidrs" {
  command = plan

  variables {
    subnet_id     = "subnet-12345678"
    key_pair_name = "test-key"
    ip_allow_ssh  = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  }
}

run "accepts_empty_cidr_list" {
  command = plan

  variables {
    subnet_id     = "subnet-12345678"
    key_pair_name = "test-key"
    ip_allow_ssh  = []
  }
}

run "accepts_valid_snapshot_retention_boundary_low" {
  command = plan

  variables {
    subnet_id               = "subnet-12345678"
    key_pair_name           = "test-key"
    snapshot_retention_days = 1
  }
}

run "accepts_valid_snapshot_retention_boundary_high" {
  command = plan

  variables {
    subnet_id               = "subnet-12345678"
    key_pair_name           = "test-key"
    snapshot_retention_days = 365
  }
}

run "accepts_valid_session_timeout_boundary_low" {
  command = plan

  variables {
    subnet_id               = "subnet-12345678"
    key_pair_name           = "test-key"
    rundeck_session_timeout = 5
  }
}

run "accepts_valid_session_timeout_boundary_high" {
  command = plan

  variables {
    subnet_id               = "subnet-12345678"
    key_pair_name           = "test-key"
    rundeck_session_timeout = 480
  }
}

run "accepts_pinned_ami_id" {
  command = plan

  variables {
    subnet_id     = "subnet-12345678"
    key_pair_name = "test-key"
    ami_id        = "ami-0123456789abcdef0"
  }
}

run "accepts_valid_instance_types" {
  command = plan

  variables {
    subnet_id     = "subnet-12345678"
    key_pair_name = "test-key"
    instance_type = "c5.xlarge"
  }
}

run "accepts_metal_instance_type" {
  command = plan

  variables {
    subnet_id     = "subnet-12345678"
    key_pair_name = "test-key"
    instance_type = "c5.metal"
  }
}

# =============================================================================
# Feature Flag Tests - Conditional Resource Creation
# =============================================================================

# Matches examples/minimal pattern: SSH + defaults only
run "minimal_defaults" {
  command = plan

  variables {
    subnet_id     = "subnet-12345678"
    key_pair_name = "test-key"
  }

  assert {
    condition     = length(aws_cloudwatch_log_group.this) == 0
    error_message = "Minimal config should not create CloudWatch log group"
  }

  assert {
    condition     = length(aws_iam_role_policy_attachment.ssm[*]) == 0
    error_message = "Minimal config should not attach SSM policy"
  }

  assert {
    condition     = length(aws_dlm_lifecycle_policy.this) == 0
    error_message = "Minimal config should not create DLM policy"
  }
}

# Matches examples/ssm-only pattern: SSM access, no SSH, no key pair
run "ssm_only_no_ssh" {
  command = plan

  variables {
    subnet_id  = "subnet-12345678"
    enable_ssh = false
    enable_ssm = true
  }

  assert {
    condition     = length(aws_iam_role_policy_attachment.ssm) == 1
    error_message = "SSM-only should attach SSM policy"
  }

  assert {
    condition     = length(aws_iam_role.this) == 1
    error_message = "SSM-only should create IAM role"
  }

  assert {
    condition     = length(aws_iam_instance_profile.this) == 1
    error_message = "SSM-only should create instance profile"
  }
}

# Matches examples/complete pattern: all features enabled
run "all_features_enabled" {
  command = plan

  variables {
    subnet_id              = "subnet-12345678"
    key_pair_name          = "test-key"
    enable_ssh             = true
    enable_ssm             = true
    enable_cloudwatch_logs = true
    enable_security_alarms = true
    create_sns_topic       = true
    alarm_email            = "test@example.com"
    enable_ebs_snapshots   = true
  }

  assert {
    condition     = length(aws_cloudwatch_log_group.this) == 1
    error_message = "Complete config should create CloudWatch log group"
  }

  assert {
    condition     = length(aws_iam_role_policy_attachment.ssm) == 1
    error_message = "Complete config should attach SSM policy"
  }

  assert {
    condition     = length(aws_sns_topic.alarms) == 1
    error_message = "Complete config should create SNS topic"
  }

  assert {
    condition     = length(aws_dlm_lifecycle_policy.this) == 1
    error_message = "Complete config should create DLM policy"
  }
}

# CloudWatch without alarms
run "cloudwatch_logs_only" {
  command = plan

  variables {
    subnet_id              = "subnet-12345678"
    key_pair_name          = "test-key"
    enable_cloudwatch_logs = true
    enable_security_alarms = false
  }

  assert {
    condition     = length(aws_cloudwatch_log_group.this) == 1
    error_message = "Should create CloudWatch log group"
  }

  assert {
    condition     = length(aws_cloudwatch_metric_alarm.cpu_usage[*]) == 0
    error_message = "Should not create alarms when disabled"
  }
}

run "spot_instance" {
  command = plan

  variables {
    subnet_id            = "subnet-12345678"
    key_pair_name        = "test-key"
    create_spot_instance = true
  }
}

run "ebs_snapshots_custom_schedule" {
  command = plan

  variables {
    subnet_id               = "subnet-12345678"
    key_pair_name           = "test-key"
    enable_ebs_snapshots    = true
    snapshot_retention_days = 30
    snapshot_time           = "03:00"
  }

  assert {
    condition     = length(aws_dlm_lifecycle_policy.this) == 1
    error_message = "Should create DLM policy when snapshots enabled"
  }
}

run "custom_name_propagates" {
  command = plan

  variables {
    subnet_id     = "subnet-12345678"
    key_pair_name = "test-key"
    name          = "my-custom-rundeck"
  }

  assert {
    condition     = aws_security_group.this.name == "my-custom-rundeck-ec2"
    error_message = "Custom name should propagate to security group"
  }
}
