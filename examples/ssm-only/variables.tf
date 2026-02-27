variable "subnet_id" {
  type        = string
  description = "Subnet ID for the EC2 instance"
}

variable "ip_allow_https" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "Allowed IPs for HTTPS access"
}
