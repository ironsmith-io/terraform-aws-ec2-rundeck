# Look up VPC from subnet
data "aws_subnet" "selected" {
  id = var.subnet_id
}

# Current AWS region and partition
data "aws_region" "current" {}
data "aws_partition" "current" {}

# Auto-discover latest Rocky Linux 9 AMI (Rocky Enterprise Software Foundation)
data "aws_ami" "rocky" {
  most_recent = true
  owners      = ["792107900819"]

  filter {
    name   = "name"
    values = ["Rocky-9-EC2-Base-9*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}
