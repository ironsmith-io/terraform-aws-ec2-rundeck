output "instance_id" {
  description = "EC2 Instance ID"
  value       = module.rundeck.instance_id
}

output "public_ip" {
  description = "Rundeck server public IP"
  value       = module.rundeck.public_ip
}

output "server_url" {
  description = "Rundeck web UI URL"
  value       = module.rundeck.server_url
}

output "ssh_command" {
  description = "SSH command to connect"
  value       = module.rundeck.ssh_command
}
