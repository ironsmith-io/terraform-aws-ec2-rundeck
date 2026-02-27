# Complete Rundeck Example

Provisions a fully-featured Rundeck EC2 instance with optional SSM, CloudWatch, and spot instance support.

## Setup

1. Copy the example tfvars file:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your values:
   ```hcl
   subnet_id     = "subnet-xxxxxxxx"
   key_pair_name = "my-keypair"
   ```

3. From the **repository root**, use Makefile commands:
   ```bash
   make init    # Initialize terraform
   make apply   # Deploy Rundeck
   make open    # Open Rundeck UI in browser
   make ssh     # SSH to instance
   make ssm     # SSM Session Manager
   ```

Note: This example creates resources which cost money. Run `make destroy` when done.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_rundeck"></a> [rundeck](#module\_rundeck) | ../../ | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alarm_email"></a> [alarm\_email](#input\_alarm\_email) | Email address for alarm notifications | `string` | `null` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | `"us-west-2"` | no |
| <a name="input_create_sns_topic"></a> [create\_sns\_topic](#input\_create\_sns\_topic) | Create an SNS topic for alarm notifications | `bool` | `false` | no |
| <a name="input_create_spot_instance"></a> [create\_spot\_instance](#input\_create\_spot\_instance) | Create an EC2 Spot Instance | `bool` | `false` | no |
| <a name="input_enable_cloudwatch_logs"></a> [enable\_cloudwatch\_logs](#input\_enable\_cloudwatch\_logs) | Enable CloudWatch Logs agent | `bool` | `false` | no |
| <a name="input_enable_ebs_snapshots"></a> [enable\_ebs\_snapshots](#input\_enable\_ebs\_snapshots) | Enable automated daily EBS snapshots via AWS Data Lifecycle Manager | `bool` | `false` | no |
| <a name="input_enable_plugin_repository"></a> [enable\_plugin\_repository](#input\_enable\_plugin\_repository) | Enable Rundeck online plugin repository | `bool` | `false` | no |
| <a name="input_enable_security_alarms"></a> [enable\_security\_alarms](#input\_enable\_security\_alarms) | Enable CloudWatch alarms for security events | `bool` | `false` | no |
| <a name="input_enable_ssh"></a> [enable\_ssh](#input\_enable\_ssh) | Enable SSH access (port 22). Set to false for SSM-only access | `bool` | `true` | no |
| <a name="input_enable_ssm"></a> [enable\_ssm](#input\_enable\_ssm) | Enable AWS Systems Manager Session Manager access | `bool` | `false` | no |
| <a name="input_enable_termination_protection"></a> [enable\_termination\_protection](#input\_enable\_termination\_protection) | Enable EC2 termination protection to prevent accidental instance deletion | `bool` | `false` | no |
| <a name="input_ip_allow_https"></a> [ip\_allow\_https](#input\_ip\_allow\_https) | Allowed IPs for HTTPS access | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_ip_allow_ssh"></a> [ip\_allow\_ssh](#input\_ip\_allow\_ssh) | Allowed IPs for SSH access | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_key_pair_name"></a> [key\_pair\_name](#input\_key\_pair\_name) | EC2 key pair name for SSH access. Create with: make keygen | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name prefix for resources | `string` | `"rundeck"` | no |
| <a name="input_rundeck_admin_password_ssm_path"></a> [rundeck\_admin\_password\_ssm\_path](#input\_rundeck\_admin\_password\_ssm\_path) | SSM Parameter Store path for Rundeck admin password (SecureString) | `string` | `null` | no |
| <a name="input_rundeck_session_timeout"></a> [rundeck\_session\_timeout](#input\_rundeck\_session\_timeout) | Rundeck web session timeout in minutes | `number` | `null` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID for the EC2 instance | `string` | n/a | yes |
| <a name="input_user_data_extra"></a> [user\_data\_extra](#input\_user\_data\_extra) | Additional shell commands appended to the end of cloud-init runcmd | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ami_id"></a> [ami\_id](#output\_ami\_id) | AMI ID used for the instance |
| <a name="output_cloudwatch_dashboard_url"></a> [cloudwatch\_dashboard\_url](#output\_cloudwatch\_dashboard\_url) | CloudWatch Operations Dashboard URL |
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#output\_cloudwatch\_log\_group\_name) | CloudWatch Log Group name |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | IAM Role ARN |
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | EC2 Instance ID |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | Rundeck server private IP |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | Rundeck server public IP |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | Security Group ID |
| <a name="output_server_url"></a> [server\_url](#output\_server\_url) | Rundeck web UI URL |
| <a name="output_sns_topic_arn"></a> [sns\_topic\_arn](#output\_sns\_topic\_arn) | SNS Topic ARN for alarm notifications |
| <a name="output_ssh_command"></a> [ssh\_command](#output\_ssh\_command) | SSH command to connect to the instance |
<!-- END_TF_DOCS -->
