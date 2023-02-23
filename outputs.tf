output "server_url" {
  value       = format("https://%s:4443", var.create_spot_instance ? aws_spot_instance_request.rundeck[0].public_ip : aws_instance.rundeck[0].public_ip)
  description = "Rundeck's HTTPS endpoint"
}

output "ec2_instance_id" {
  value       = var.create_spot_instance ? aws_spot_instance_request.rundeck[0].spot_instance_id : aws_instance.rundeck[0].id
  description = "The Rundeck EC2 Instance ID"
}

output "security_group_id" {
  value       = aws_security_group.rundeck.id
  description = "The Rundeck EC2 Security Group ID"
}

output "public_ip" {
  value       = var.create_spot_instance ? aws_spot_instance_request.rundeck[0].public_ip : aws_instance.rundeck[0].public_ip
  description = "The Rundeck Server's Public IP"
}
