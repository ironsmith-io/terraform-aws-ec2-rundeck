# Latest Centos 7 AMI
data "aws_ami" "rundeck" {
  most_recent = true
  owners      = ["125523088429"]
  filter {
    name   = "name"
    values = ["CentOS 7.9.2009 x86_*"]
  }
}
