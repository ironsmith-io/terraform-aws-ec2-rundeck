variable "aws_vpc_id" {
  type        = string
  description = "AWS VPC Identifier"
  validation {
    condition     = length(var.aws_vpc_id) > 11
    error_message = "Invalid AWS VPC ID."
  }
}

variable "aws_subnet_id" {
  type        = string
  description = "Public subnet that hosts Rundeck EC2 instance"
  validation {
    condition     = length(var.aws_subnet_id) > 7
    error_message = "Invalid AWS Subnet ID."
  }
}

variable "key_pair_name" {
  type        = string
  description = "EC2 Key pair for Rundeck host"
  validation {
    condition     = length(var.key_pair_name) > 0
    error_message = "EC2 Key pair name must be provided."
  }
}

variable "instance_type" {
  type        = string
  default     = "c5.large"
  description = "EC2 Instance Type"
  validation {
    condition     = can(regex("^([a-z]+\\d+\\.[a-z]+)/?$", var.instance_type))
    error_message = "Invalid EC2 instance type format."
  }
}

variable "ip_allow_ssh" {
  type        = set(string)
  default     = ["0.0.0.0/0"]
  description = "Allowed IPs for SSH to Rundeck host"
  validation {
    condition = alltrue([
      for a in var.ip_allow_ssh : can(cidrnetmask(a))
    ])
    error_message = "All elements must be valid IPv4 CIDR block addresses."
  }
}

variable "ip_allow_https" {
  type        = set(string)
  default     = ["0.0.0.0/0"]
  description = "Allowed IPs for HTTPS to Rundeck host"
  validation {
    condition = alltrue([
      for a in var.ip_allow_https : can(cidrnetmask(a))
    ])
    error_message = "All elements must be valid IPv4 CIDR block addresses."
  }
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

variable "aws_iam_policy_arns" {
  type        = list(string)
  default     = []
  description = "AWS IAM Policy ARNs."
  validation {
    condition     = length(var.aws_iam_policy_arns) <= 10
    error_message = "Number of AWS IAM Policy ARNs should be 10 or less."
  }
}

variable "create_spot_instance" {
  type        = bool
  default     = false
  description = "Create an EC2 Spot Instance"
}

variable "rdeck_jvm_settings" {
  type        = string
  default     = null
  description = "Rundeck JVM Options"
}

variable "tags" {
  type = map(string)
  default = {
    Name    = "Rundeck"
    app     = "rundeck"
    role    = "app"
    ver     = "0.0.1"
    contact = "hello@ironsmith.io"
    env     = "dev"
    prov    = "terraform"
  }
  description = "Tags to use on AWS resources"
}
