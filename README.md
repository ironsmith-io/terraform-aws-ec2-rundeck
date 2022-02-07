<!-- BEGIN_TF_DOCS -->
# AWS EC2 Rundeck Terraform module

Terraform module that creates a Rundeck EC2 (spot) instance.

## Usage

### Create new EC2 Rundeck server

```hcl

module "rundeck" {
  source            = "git@github.com:rundeck-io/terraform-aws-ec2.git"
  aws_vpc_id        = data.aws_vpc.default.id
  aws_subnet_id     = data.aws_subnet.default.id
  key_pair_name     = "rundeck-us-west-2"
  ip_allow_ssh      = ["0.0.0.0/0"]
  ip_allow_https    = ["0.0.0.0/0"]
}

```

## Examples:

- [default-vpc](https://github.com/rundeck-io/terraform-aws-ec2/tree/master/examples/default-vpc) - Creates Rundeck EC2 instance on Default VPC

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.50.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.50.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ec2_tag.rundeck](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_tag) | resource |
| [aws_security_group.rundeck](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_spot_instance_request.rundeck](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/spot_instance_request) | resource |
| [aws_ami.rundeck](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_subnet_id"></a> [aws\_subnet\_id](#input\_aws\_subnet\_id) | Public subnet that hosts Rundeck EC2 instance | `string` | n/a | yes |
| <a name="input_aws_vpc_id"></a> [aws\_vpc\_id](#input\_aws\_vpc\_id) | AWS VPC Identifier | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 Instance Type | `string` | `"c5.large"` | no |
| <a name="input_ip_allow_https"></a> [ip\_allow\_https](#input\_ip\_allow\_https) | Allowed IPs for HTTPS to Rundeck host | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_ip_allow_ssh"></a> [ip\_allow\_ssh](#input\_ip\_allow\_ssh) | Allowed IPs for SSH to Rundeck host | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_key_pair_name"></a> [key\_pair\_name](#input\_key\_pair\_name) | EC2 Key pair for Rundeck host | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_server_url"></a> [server\_url](#output\_server\_url) | Rundeck's HTTPS endpoint |
<!-- END_TF_DOCS -->