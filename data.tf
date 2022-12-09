# Latest Centos 7 AMI from Centos.org
# https://centos.org/download/aws-images/
data "aws_ami" "rundeck" {
  most_recent = true
  owners      = ["125523088429"]
  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64*"]
  }
}
