# SSM-Only Rundeck Example

Deploys Rundeck with SSM Session Manager access only. No SSH, no EC2 key pair required.

Port 22 is not opened. Connect via:

```bash
aws ssm start-session --target $(terraform output -raw instance_id)
```

## Usage

```bash
cat > terraform.tfvars << EOF
subnet_id      = "subnet-xxxxxxxx"
ip_allow_https = ["0.0.0.0/0"]
EOF

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
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID for the EC2 instance | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | EC2 Instance ID (use with: aws ssm start-session --target <id>) |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | Rundeck server public IP |
| <a name="output_server_url"></a> [server\_url](#output\_server\_url) | Rundeck web UI URL |
<!-- END_TF_DOCS -->
