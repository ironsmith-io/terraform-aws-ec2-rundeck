# Minimal Rundeck Example

This example deploys Rundeck with minimal configuration using only the required variables.

## What You Get

- Rundeck server with default settings
- SSH access enabled (port 22)
- HTTPS access enabled (port 443)
- No CloudWatch Logs (enable with `enable_cloudwatch_logs = true`)
- No SSM Session Manager
- No EBS snapshots

## Usage

```bash
# Create terraform.tfvars
cat > terraform.tfvars << EOF
subnet_id      = "subnet-xxxxxxxx"
key_pair_name  = "my-keypair"
ip_allow_ssh   = ["10.0.0.0/8"]     # Your admin CIDR
ip_allow_https = ["0.0.0.0/0"]      # Web UI access
EOF

# Deploy
terraform init
terraform apply
```

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
| <a name="input_ip_allow_https"></a> [ip\_allow\_https](#input\_ip\_allow\_https) | Allowed IPs for HTTPS access | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_ip_allow_ssh"></a> [ip\_allow\_ssh](#input\_ip\_allow\_ssh) | Allowed IPs for SSH access | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_key_pair_name"></a> [key\_pair\_name](#input\_key\_pair\_name) | EC2 key pair name for SSH access | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Public subnet ID for Rundeck EC2 instance | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | EC2 Instance ID |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | Rundeck server public IP |
| <a name="output_server_url"></a> [server\_url](#output\_server\_url) | Rundeck web UI URL |
| <a name="output_ssh_command"></a> [ssh\_command](#output\_ssh\_command) | SSH command to connect |
<!-- END_TF_DOCS -->
