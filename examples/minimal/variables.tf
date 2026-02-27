variable "subnet_id" {
  type        = string
  description = "Public subnet ID for Rundeck EC2 instance"
}

variable "key_pair_name" {
  type        = string
  description = "EC2 key pair name for SSH access"
}

variable "ip_allow_ssh" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "Allowed IPs for SSH access"
}

variable "ip_allow_https" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "Allowed IPs for HTTPS access"
}
