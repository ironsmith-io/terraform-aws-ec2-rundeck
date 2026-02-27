provider "aws" {
  region = var.aws_region
}

module "rundeck" {
  source                          = "../../"
  subnet_id                       = var.subnet_id
  key_pair_name                   = var.key_pair_name
  name                            = var.name
  create_spot_instance            = var.create_spot_instance
  enable_cloudwatch_logs          = var.enable_cloudwatch_logs
  enable_ssm                      = var.enable_ssm
  enable_ssh                      = var.enable_ssh
  enable_ebs_snapshots            = var.enable_ebs_snapshots
  ip_allow_ssh                    = var.ip_allow_ssh
  ip_allow_https                  = var.ip_allow_https
  rundeck_admin_password_ssm_path = var.rundeck_admin_password_ssm_path
  enable_security_alarms          = var.enable_security_alarms
  create_sns_topic                = var.create_sns_topic
  alarm_email                     = var.alarm_email
  rundeck_session_timeout         = var.rundeck_session_timeout
  enable_plugin_repository        = var.enable_plugin_repository
  enable_termination_protection   = var.enable_termination_protection
  user_data_extra                 = var.user_data_extra
}
