# rundeck ec2 instance
resource "aws_instance" "rundeck" {
  count                  = var.create_spot_instance ? 0 : 1
  ami                    = data.aws_ami.rundeck.id
  key_name               = var.key_pair_name
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.rundeck.id]
  subnet_id              = var.aws_subnet_id
  tags                   = local.common_tags
  user_data              = file("${path.module}/user_data.sh")
  iam_instance_profile   = local.use_instance_profile ? aws_iam_instance_profile.rundeck[0].name : null

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.root_volume_size
    delete_on_termination = true
    encrypted             = var.root_encrypted
    tags                  = local.common_tags
  }
}

# Spot Instance
resource "aws_spot_instance_request" "rundeck" {
  count                          = var.create_spot_instance ? 1 : 0
  ami                            = data.aws_ami.rundeck.id
  key_name                       = var.key_pair_name
  instance_type                  = var.instance_type
  instance_interruption_behavior = "stop"
  wait_for_fulfillment           = true
  vpc_security_group_ids         = [aws_security_group.rundeck.id]
  subnet_id                      = var.aws_subnet_id
  tags                           = local.common_tags
  user_data                      = file("${path.module}/user_data.sh")
  iam_instance_profile           = local.use_instance_profile ? aws_iam_instance_profile.rundeck[0].name : null

  ebs_block_device {
    device_name           = "/dev/sda1"
    encrypted             = var.root_encrypted
    volume_size           = var.root_volume_size
    delete_on_termination = true
    volume_type           = "gp3"
    tags                  = local.common_tags
  }
}

# resource "aws_ec2_tag" "rundeck" {
#   resource_id = aws_spot_instance_request.rundeck[0].spot_instance_id
#   for_each    = local.common_tags
#   key         = each.key
#   value       = each.value
# }

# tag spot instance
resource "aws_ec2_tag" "rundeck" {
  resource_id = var.create_spot_instance ? aws_spot_instance_request.rundeck[0].spot_instance_id : aws_instance.rundeck[0].id
  for_each    = local.common_tags
  key         = each.key
  value       = each.value
}

# Rundeck host Security Group
resource "aws_security_group" "rundeck" {
  name        = "rundeck-io-ec2"
  description = "Allow for Rundeck Servers"
  vpc_id      = var.aws_vpc_id
  tags        = local.common_tags

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    description = "Allow SSH"
    cidr_blocks = var.ip_allow_ssh
  }

  ingress {
    from_port   = 4443
    to_port     = 4443
    protocol    = "TCP"
    description = "Allow HTTPS"
    cidr_blocks = var.ip_allow_https
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Instance profile for rundeck host, only if ARNs passed into module
resource "aws_iam_instance_profile" "rundeck" {
  count = local.use_instance_profile ? 1 : 0
  name  = "rundeck-io-instance-profile"
  role  = aws_iam_role.rundeck[count.index].name
  tags  = local.common_tags
}

# IAM role for rundeck host, only if ARNs passed into module
resource "aws_iam_role" "rundeck" {
  count = local.use_instance_profile ? 1 : 0
  name  = "rundeck-io-role"
  tags  = local.common_tags
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach IAM policy to rundeck role, only if ARNs passed into module
resource "aws_iam_role_policy_attachment" "rundeck_managed" {
  count      = length(var.aws_iam_policy_arns)
  role       = aws_iam_role.rundeck[0].name
  policy_arn = var.aws_iam_policy_arns[count.index]
}
