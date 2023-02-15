output "server_url" {
  value       = module.rundeck.server_url
  description = "HTTPS endpoint of Rundeck host"
}

output "ec2_instance_id" {
  value       = module.rundeck.ec2_instance_id
  description = "The Rundeck EC2 Instance ID"
}
