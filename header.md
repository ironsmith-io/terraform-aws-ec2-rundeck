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


