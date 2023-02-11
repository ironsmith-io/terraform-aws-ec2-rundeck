
# Spot Instance
resource "aws_spot_instance_request" "rundeck" {
  ami                            = data.aws_ami.rundeck.id
  key_name                       = var.key_pair_name
  instance_type                  = var.instance_type
  instance_interruption_behavior = "stop"
  wait_for_fulfillment           = true
  vpc_security_group_ids         = [aws_security_group.rundeck.id]
  subnet_id                      = var.aws_subnet_id
  tags                           = local.common_tags
  user_data                      = file("${path.module}/user_data.sh")

  root_block_device {
    encrypted             = false
    volume_size           = var.root_volume_size
    delete_on_termination = true
    volume_type           = "gp3"
    tags                  = local.common_tags
  }
}

resource "aws_ec2_tag" "rundeck" {
  resource_id = aws_spot_instance_request.rundeck.spot_instance_id
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
