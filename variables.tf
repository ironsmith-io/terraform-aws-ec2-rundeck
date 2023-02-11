variable "aws_vpc_id" {
  type        = string
  description = "AWS VPC Identifier"
}

variable "aws_subnet_id" {
  type        = string
  description = "Public subnet that hosts Rundeck EC2 instance"
}

variable "key_pair_name" {
  type        = string
  description = "EC2 Key pair for Rundeck host"
}

variable "instance_type" {
  type        = string
  default     = "c5.large"
  description = "EC2 Instance Type"
}

variable "ip_allow_ssh" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "Allowed IPs for SSH to Rundeck host"
}

variable "ip_allow_https" {
  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = "Allowed IPs for HTTPS to Rundeck host"
}

variable "root_volume_size" {
  type        = number
  default     = 8
  description = "EC2 root volume size"
}

variable "root_encrypted" {
  type        = bool
  default     = false
  description = "Encrypt EC2 root volume"
}
