# AWS EC2 Rundeck Terraform module

Terraform module that creates a Rundeck EC2 (spot) instance.

## Usage

### Create new EC2 Rundeck server

```hcl

module "rundeck" {
  source            = "git@github.com:rundeck-io/terraform-aws-ec2-rundeck.git"
  aws_vpc_id        = data.aws_vpc.default.id
  aws_subnet_id     = data.aws_subnet.default.id
  key_pair_name     = "rundeck-us-west-2"

  # OPTIONALS           = defaults
  # ip_allow_ssh        = ["0.0.0.0/0"]
  # ip_allow_https      = ["0.0.0.0/0"]
  # root_volume_size    = 8
  # root_encrypted      = false
  # instance_type       = "c5.large"
  # aws_iam_policy_arns = []
  
  # example useage
    #   aws_iam_policy_arns = [
    #     "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    #     "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess",
    #     aws_iam_policy.rundeck.arn
    #   ]

}

```

## Examples:

- [default-vpc](https://github.com/rundeck-io/terraform-aws-ec2-rundeck/tree/master/examples/default-vpc) - Creates Rundeck EC2 instance on Default VPC

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
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
| [aws_iam_instance_profile.rundeck](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.rundeck](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.rundeck_managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.rundeck](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_security_group.rundeck](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_spot_instance_request.rundeck](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/spot_instance_request) | resource |
| [aws_ami.rundeck](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_iam_policy_arns"></a> [aws\_iam\_policy\_arns](#input\_aws\_iam\_policy\_arns) | AWS IAM Policy ARNs | `list(string)` | `[]` | no |
| <a name="input_aws_subnet_id"></a> [aws\_subnet\_id](#input\_aws\_subnet\_id) | Public subnet that hosts Rundeck EC2 instance | `string` | n/a | yes |
| <a name="input_aws_vpc_id"></a> [aws\_vpc\_id](#input\_aws\_vpc\_id) | AWS VPC Identifier | `string` | n/a | yes |
| <a name="input_create_spot_instance"></a> [create\_spot\_instance](#input\_create\_spot\_instance) | Create an EC2 Spot Instance | `bool` | `false` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 Instance Type | `string` | `"c5.large"` | no |
| <a name="input_ip_allow_https"></a> [ip\_allow\_https](#input\_ip\_allow\_https) | Allowed IPs for HTTPS to Rundeck host | `set(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_ip_allow_ssh"></a> [ip\_allow\_ssh](#input\_ip\_allow\_ssh) | Allowed IPs for SSH to Rundeck host | `set(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_key_pair_name"></a> [key\_pair\_name](#input\_key\_pair\_name) | EC2 Key pair for Rundeck host | `string` | n/a | yes |
| <a name="input_root_encrypted"></a> [root\_encrypted](#input\_root\_encrypted) | Encrypt EC2 root volume | `bool` | `false` | no |
| <a name="input_root_volume_size"></a> [root\_volume\_size](#input\_root\_volume\_size) | EC2 root volume size | `number` | `8` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ec2_instance_id"></a> [ec2\_instance\_id](#output\_ec2\_instance\_id) | The Rundeck EC2 Instance ID |
| <a name="output_server_url"></a> [server\_url](#output\_server\_url) | Rundeck's HTTPS endpoint |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
