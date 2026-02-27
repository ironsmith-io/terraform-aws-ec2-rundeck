variable "aws_region" {
  type        = string
  default     = "us-west-2"
  description = "AWS region"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID for the EC2 instance"
}

variable "name" {
  type        = string
  default     = "rundeck"
  description = "Name prefix for resources"
}

variable "key_pair_name" {
  type        = string
  default     = null
  description = "EC2 key pair name for SSH access. Create with: make keygen"
}

variable "create_spot_instance" {
  type        = bool
  default     = false
  description = "Create an EC2 Spot Instance"
}

variable "enable_ssm" {
  type        = bool
  default     = false
  description = "Enable AWS Systems Manager Session Manager access"
}

variable "enable_cloudwatch_logs" {
  type        = bool
  default     = false
  description = "Enable CloudWatch Logs agent"
}

variable "enable_ssh" {
  type        = bool
  default     = true
  description = "Enable SSH access (port 22). Set to false for SSM-only access"
}

variable "enable_ebs_snapshots" {
  type        = bool
  default     = false
  description = "Enable automated daily EBS snapshots via AWS Data Lifecycle Manager"
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

variable "rundeck_admin_password_ssm_path" {
  type        = string
  default     = null
  description = "SSM Parameter Store path for Rundeck admin password (SecureString)"
}

variable "enable_security_alarms" {
  type        = bool
  default     = false
  description = "Enable CloudWatch alarms for security events"
}

variable "create_sns_topic" {
  type        = bool
  default     = false
  description = "Create an SNS topic for alarm notifications"
}

variable "alarm_email" {
  type        = string
  default     = null
  description = "Email address for alarm notifications"
}

variable "rundeck_session_timeout" {
  type        = number
  default     = null
  description = "Rundeck web session timeout in minutes"
}

variable "enable_plugin_repository" {
  type        = bool
  default     = false
  description = "Enable Rundeck online plugin repository"
}

variable "enable_termination_protection" {
  type        = bool
  default     = false
  description = "Enable EC2 termination protection to prevent accidental instance deletion"
}

variable "user_data_extra" {
  type        = string
  default     = ""
  description = "Additional shell commands appended to the end of cloud-init runcmd"
}
