output "server_url" {
  value       = format("https://%s:4443", aws_spot_instance_request.rundeck.public_ip)
  description = "Rundeck's HTTPS endpoint"
}
