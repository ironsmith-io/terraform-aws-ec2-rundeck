# AWS EC2 Rundeck Terraform module

[![Terraform Registry](https://img.shields.io/badge/terraform-registry-blue.svg)](https://registry.terraform.io/modules/ironsmith-io/ec2-rundeck/aws)
[![CI](https://github.com/ironsmith-io/terraform-aws-ec2-rundeck/actions/workflows/ci.yml/badge.svg)](https://github.com/ironsmith-io/terraform-aws-ec2-rundeck/actions/workflows/ci.yml)

Terraform module that deploys a production-ready Rundeck server on AWS EC2.

## Overview

This module provisions a fully configured Rundeck instance with:

- **Rocky Linux 9.x** base AMI (auto-discovered)
- **PostgreSQL 16** database backend (SCRAM-SHA-256 auth)
- **nginx** reverse proxy with Let's Encrypt TLS certificate (auto-renewing)
- **IMDSv2** enforced for security
- **EBS encryption** always enabled
- **Spot instance** support for cost savings

## Architecture

```
                                    Internet
                                        │
                                        ▼
                            ┌───────────────────────┐
                            │   Security Group      │
                            │   ─────────────────   │
                            │   22/SSH (optional)   │
                            │   80/HTTP  (redirect) │
                            │   443/HTTPS           │
                            └───────────┬───────────┘
                                        │
                                        ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                              EC2 Instance                                   │
│                           (Rocky Linux 9.x)                                 │
│                                                                             │
│   ┌─────────────────┐      ┌─────────────────┐      ┌─────────────────┐   │
│   │     nginx       │      │    Rundeck      │      │  PostgreSQL 16  │   │
│   │  (reverse proxy)│─────▶│   (Java App)    │─────▶│  (SCRAM-SHA-256)│   │
│   │   :443/:80      │      │   :4440         │      │   :5432         │   │
│   │                 │      │   (localhost)    │      │   (localhost)   │   │
│   └─────────────────┘      └─────────────────┘      └─────────────────┘   │
│          │                         │                                       │
│          │   TLS (Let's Encrypt)   │   JVM (-Xmx1g)                       │
│          │   Auto-renewing         │   G1GC                                │
│                                                                             │
│   EBS Volume (gp3, encrypted)                                               │
└─────────────────────────────────────────────────────────────────────────────┘
        │                           │                           │
        ▼                           ▼                           ▼
┌───────────────┐         ┌─────────────────┐         ┌─────────────────┐
│  CloudWatch   │         │  SSM Parameter  │         │   DLM (EBS      │
│  Logs/Metrics │         │     Store       │         │   Snapshots)    │
│  Dashboards   │         │  (password)     │         │   (optional)    │
│  Alarms       │         │                 │         │                 │
└───────────────┘         └─────────────────┘         └─────────────────┘
```

## Features

| Feature | Description |
|---------|-------------|
| Spot Instances | Cost savings with `create_spot_instance = true` |
| SSM Session Manager | SSH-less access with `enable_ssm = true` |
| CloudWatch Integration | Logs, metrics, dashboards, and alarms |
| Conditional SSH | Disable port 22 with `enable_ssh = false` for SSM-only access |
| Custom IAM Policies | Attach policies via `aws_iam_policy_arns` |
| EBS Snapshots | Automated daily backups via DLM with `enable_ebs_snapshots = true` |
| Termination Protection | Prevent accidental deletion with `enable_termination_protection = true` |
| GovCloud Support | Works in AWS GovCloud and China regions |

## Prerequisites

- AWS account with appropriate permissions
- VPC with a public subnet
- EC2 key pair (for SSH access; not needed with SSM-only)

## Usage

### Basic Example

```hcl
module "rundeck" {
  source    = "ironsmith-io/ec2-rundeck/aws"
  version   = "1.0.0"
  subnet_id = "subnet-xxxxxxxx"

  # SSH access
  key_pair_name = "my-keypair"
  ip_allow_ssh  = ["10.0.0.0/8"]

  # Web UI access
  ip_allow_https = ["0.0.0.0/0"]
}
```

### Full Example with All Features

```hcl
module "rundeck" {
  source    = "ironsmith-io/ec2-rundeck/aws"
  version   = "1.0.0"
  subnet_id = var.subnet_id

  # SSH access
  key_pair_name = var.key_pair_name
  ip_allow_ssh  = ["10.0.0.0/8"]
  ip_allow_https = ["0.0.0.0/0"]

  # Feature flags
  enable_cloudwatch_logs = true
  enable_ssm             = true
  enable_ebs_snapshots   = true

  # Monitoring & alarms
  enable_security_alarms = true
  create_sns_topic       = true
  alarm_email            = "alerts@example.com"

  # Rundeck configuration
  rundeck_admin_password_ssm_path = "/rundeck/admin-password"
  rundeck_session_timeout         = 30

  # Instance configuration
  instance_type    = "c5.large"
  root_volume_size = 20
}
```

### SSM-Only (No SSH)

```hcl
module "rundeck" {
  source         = "ironsmith-io/ec2-rundeck/aws"
  version        = "1.0.0"
  subnet_id      = "subnet-xxxxxxxx"
  enable_ssm     = true
  enable_ssh     = false
  ip_allow_https = ["0.0.0.0/0"]
}
```

## Access Combinations

| enable_ssm | enable_ssh | Result |
|------------|------------|--------|
| false | true | SSH only (traditional) |
| true | true | Both SSH and SSM available |
| true | false | SSM only (most secure, no port 22) |
| false | false | No remote access (web UI only) |

## Quick Reference

| Item | Value |
|------|-------|
| SSH User | `rocky` |
| Default Credentials | `admin` / `admin` |
| Rundeck URL | `https://<public_ip>` |
| TLS Certificate | Let's Encrypt (auto-renewing) |
| Database | PostgreSQL 16 (localhost) |

**Security:** Change the default Rundeck admin password after deployment, or use SSM Parameter Store:

```bash
# Store password in SSM (run once)
aws ssm put-parameter \
  --name "/rundeck/admin-password" \
  --type "SecureString" \
  --value "$(openssl rand -base64 24 | tr -dc 'a-zA-Z0-9' | head -c 24)"
```

Then set `rundeck_admin_password_ssm_path = "/rundeck/admin-password"` in the module.

## Data Protection

### EBS Volume Preservation

By default, the EBS root volume is **preserved** when the instance is terminated (`delete_volume_on_termination = false`).

### EBS Snapshots

```hcl
module "rundeck" {
  # ...
  enable_ebs_snapshots    = true
  snapshot_retention_days = 30
}
```

### Spot Instances Warning

Spot instances can be **terminated by AWS at any time**. Use only for evaluation and testing, not production.

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| Certificate error in browser | Let's Encrypt IP cert not trusted | Click "Advanced" > "Proceed" (expected for IP-based certs) |
| SSH connection refused | Port 22 not open | Check `ip_allow_ssh` CIDR and `enable_ssh` setting |
| Rundeck login fails | Wrong credentials | Default is `admin`/`admin`, or check SSM path |
| 502 Bad Gateway | Rundeck not running | SSH in: `sudo systemctl status rundeckd` |

### Debug Commands

```bash
make ssh          # SSH into instance
make ssm          # SSM Session Manager (if enabled)
make status       # Check nginx, rundeckd, postgresql-16
make cloud-init   # View cloud-init provisioning log
make rundeck-log  # View Rundeck service log
```

### Log Locations

| Log | Path |
|-----|------|
| Cloud-init | `/var/log/cloud-init-output.log` |
| Rundeck | `/var/log/rundeck/service.log` |
| nginx | `/var/log/nginx/error.log` |
| PostgreSQL | `/var/lib/pgsql/16/data/log/` |
| SSH/Auth | `/var/log/secure` |

## Development

See [CHANGELOG.md](CHANGELOG.md) for version history.

### Quick Start

```bash
git clone https://github.com/ironsmith-io/terraform-aws-ec2-rundeck.git
cd terraform-aws-ec2-rundeck
make setup                    # Check prerequisites, create .envrc
# Edit .envrc: set AWS_PROFILE, TF_VAR_subnet_id, TF_VAR_key_pair_name
direnv allow
make init && make apply       # Deploy (defaults to examples/complete)
make open                     # Open Rundeck UI
make ssh                      # Connect via SSH
```

### Testing

```bash
make test              # Static analysis + unit tests (no AWS, fast)
make test-integration  # Terratest (deploys real resources)
make test-all          # Everything
```

## Examples

- [complete](examples/complete) - All features enabled
- [minimal](examples/minimal) - Minimal deployment with SSH access only
- [ssm-only](examples/ssm-only) - SSM Session Manager access, no SSH

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0, < 7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0, < 7.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_dashboard.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_dashboard) | resource |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_metric_filter.failed_ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_metric_filter) | resource |
| [aws_cloudwatch_metric_alarm.cpu_usage](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.disk_usage](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.failed_ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.nginx_process](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.postgres_process](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.rundeck_process](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.status_check](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_dlm_lifecycle_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dlm_lifecycle_policy) | resource |
| [aws_iam_instance_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.dlm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.dlm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.ssm_parameters](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_sns_topic.alarms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_subscription.email](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_ami.rocky](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_subnet.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_security_group_ids"></a> [additional\_security\_group\_ids](#input\_additional\_security\_group\_ids) | Additional security group IDs to attach to the instance | `list(string)` | `[]` | no |
| <a name="input_alarm_email"></a> [alarm\_email](#input\_alarm\_email) | Email address for alarm notifications | `string` | `null` | no |
| <a name="input_alarm_sns_topic_arn"></a> [alarm\_sns\_topic\_arn](#input\_alarm\_sns\_topic\_arn) | Existing SNS Topic ARN for CloudWatch alarm notifications | `string` | `null` | no |
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | Specific AMI ID to use. If null, auto-discovers the latest Rocky Linux 9 AMI. | `string` | `null` | no |
| <a name="input_aws_iam_policy_arns"></a> [aws\_iam\_policy\_arns](#input\_aws\_iam\_policy\_arns) | Additional managed IAM policy ARNs to attach to the instance role | `list(string)` | `[]` | no |
| <a name="input_cloudwatch_kms_key_id"></a> [cloudwatch\_kms\_key\_id](#input\_cloudwatch\_kms\_key\_id) | KMS Key ARN for CloudWatch Logs encryption. If null, CloudWatch internal encryption is used. | `string` | `null` | no |
| <a name="input_cloudwatch_log_retention_days"></a> [cloudwatch\_log\_retention\_days](#input\_cloudwatch\_log\_retention\_days) | CloudWatch Logs retention in days | `number` | `365` | no |
| <a name="input_create_sns_topic"></a> [create\_sns\_topic](#input\_create\_sns\_topic) | Create an SNS topic for alarm notifications. If false, use alarm\_sns\_topic\_arn for existing topic. | `bool` | `false` | no |
| <a name="input_create_spot_instance"></a> [create\_spot\_instance](#input\_create\_spot\_instance) | Create an EC2 Spot Instance. Warning: spot instances can be interrupted by AWS. | `bool` | `false` | no |
| <a name="input_delete_volume_on_termination"></a> [delete\_volume\_on\_termination](#input\_delete\_volume\_on\_termination) | Delete EBS root volume when instance is terminated. Set to false to preserve data. | `bool` | `false` | no |
| <a name="input_enable_cloudwatch_logs"></a> [enable\_cloudwatch\_logs](#input\_enable\_cloudwatch\_logs) | Enable CloudWatch agent to ship logs and metrics | `bool` | `false` | no |
| <a name="input_enable_ebs_snapshots"></a> [enable\_ebs\_snapshots](#input\_enable\_ebs\_snapshots) | Enable automated daily EBS snapshots via AWS Data Lifecycle Manager | `bool` | `false` | no |
| <a name="input_enable_plugin_repository"></a> [enable\_plugin\_repository](#input\_enable\_plugin\_repository) | Enable Rundeck online plugin repository. When disabled, plugins must be pre-installed or deployed via Terraform. | `bool` | `false` | no |
| <a name="input_enable_security_alarms"></a> [enable\_security\_alarms](#input\_enable\_security\_alarms) | Enable CloudWatch alarms for infrastructure events (failed SSH, disk space, CPU, process monitoring) | `bool` | `false` | no |
| <a name="input_enable_ssh"></a> [enable\_ssh](#input\_enable\_ssh) | Enable SSH access (port 22). Set to false for SSM-only access. | `bool` | `true` | no |
| <a name="input_enable_ssm"></a> [enable\_ssm](#input\_enable\_ssm) | Enable AWS Systems Manager Session Manager access | `bool` | `false` | no |
| <a name="input_enable_termination_protection"></a> [enable\_termination\_protection](#input\_enable\_termination\_protection) | Enable EC2 termination protection to prevent accidental instance deletion | `bool` | `false` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type | `string` | `"c5.large"` | no |
| <a name="input_ip_allow_https"></a> [ip\_allow\_https](#input\_ip\_allow\_https) | CIDR blocks allowed HTTPS access (ports 80/443). Empty default requires explicit configuration. | `set(string)` | `[]` | no |
| <a name="input_ip_allow_ssh"></a> [ip\_allow\_ssh](#input\_ip\_allow\_ssh) | CIDR blocks allowed SSH access. Empty default requires explicit configuration. | `set(string)` | `[]` | no |
| <a name="input_key_pair_name"></a> [key\_pair\_name](#input\_key\_pair\_name) | EC2 key pair name for SSH access. Required when enable\_ssh = true. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name tag for the EC2 instance and related resources | `string` | `"rundeck"` | no |
| <a name="input_root_volume_size"></a> [root\_volume\_size](#input\_root\_volume\_size) | Root EBS volume size in GB | `number` | `10` | no |
| <a name="input_rundeck_admin_password_ssm_path"></a> [rundeck\_admin\_password\_ssm\_path](#input\_rundeck\_admin\_password\_ssm\_path) | SSM Parameter Store path for Rundeck admin password (SecureString). If null, uses default admin/admin credentials. | `string` | `null` | no |
| <a name="input_rundeck_jvm_settings"></a> [rundeck\_jvm\_settings](#input\_rundeck\_jvm\_settings) | JVM settings for Rundeck (heap, GC, etc.). Default 1GB heap suits c5.large (4GB). For c5.xlarge+ use -Xmx2g -Xms2g | `string` | `"-Xmx1g -Xms1g -XX:MaxMetaspaceSize=256m -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -server"` | no |
| <a name="input_rundeck_session_timeout"></a> [rundeck\_session\_timeout](#input\_rundeck\_session\_timeout) | Rundeck web session timeout in minutes | `number` | `30` | no |
| <a name="input_snapshot_retention_days"></a> [snapshot\_retention\_days](#input\_snapshot\_retention\_days) | Number of days to retain EBS snapshots | `number` | `7` | no |
| <a name="input_snapshot_time"></a> [snapshot\_time](#input\_snapshot\_time) | Time of day (UTC) to take daily EBS snapshots (HH:MM format) | `string` | `"05:00"` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet to launch the EC2 instance into. VPC is derived automatically. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to merge with module defaults | `map(string)` | `{}` | no |
| <a name="input_user_data_extra"></a> [user\_data\_extra](#input\_user\_data\_extra) | Additional shell commands appended to the end of cloud-init runcmd | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ami_id"></a> [ami\_id](#output\_ami\_id) | AMI ID used for the instance (useful when auto-discovered) |
| <a name="output_ami_name"></a> [ami\_name](#output\_ami\_name) | AMI name (from data source) |
| <a name="output_cloudwatch_dashboard_url"></a> [cloudwatch\_dashboard\_url](#output\_cloudwatch\_dashboard\_url) | CloudWatch Operations Dashboard URL (when CloudWatch is enabled) |
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#output\_cloudwatch\_log\_group\_name) | CloudWatch Log Group name (when CloudWatch is enabled) |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | IAM role ARN (when instance profile is created) |
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | EC2 instance ID |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | Private IP address |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | Public IP address (if assigned) |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | Security group ID |
| <a name="output_server_url"></a> [server\_url](#output\_server\_url) | Rundeck web UI URL (HTTPS) |
| <a name="output_sns_topic_arn"></a> [sns\_topic\_arn](#output\_sns\_topic\_arn) | SNS Topic ARN for alarm notifications (when create\_sns\_topic is true) |
| <a name="output_ssh_command"></a> [ssh\_command](#output\_ssh\_command) | SSH command to connect to the instance |
<!-- END_TF_DOCS -->
