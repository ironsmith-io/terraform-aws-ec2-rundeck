output "instance_id" {
  value       = module.rundeck.instance_id
  description = "EC2 Instance ID"
}

output "public_ip" {
  value       = module.rundeck.public_ip
  description = "Rundeck server public IP"
}

output "private_ip" {
  value       = module.rundeck.private_ip
  description = "Rundeck server private IP"
}

output "server_url" {
  value       = module.rundeck.server_url
  description = "Rundeck web UI URL"
}

output "ami_id" {
  value       = module.rundeck.ami_id
  description = "AMI ID used for the instance"
}

output "security_group_id" {
  value       = module.rundeck.security_group_id
  description = "Security Group ID"
}

output "iam_role_arn" {
  value       = module.rundeck.iam_role_arn
  description = "IAM Role ARN"
}

output "cloudwatch_dashboard_url" {
  value       = module.rundeck.cloudwatch_dashboard_url
  description = "CloudWatch Operations Dashboard URL"
}

output "cloudwatch_log_group_name" {
  value       = module.rundeck.cloudwatch_log_group_name
  description = "CloudWatch Log Group name"
}

output "sns_topic_arn" {
  value       = module.rundeck.sns_topic_arn
  description = "SNS Topic ARN for alarm notifications"
}

output "ssh_command" {
  value       = module.rundeck.ssh_command
  description = "SSH command to connect to the instance"
}
