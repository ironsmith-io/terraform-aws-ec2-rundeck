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


