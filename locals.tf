locals {
  ami_id = var.ami_id != null ? var.ami_id : data.aws_ami.rocky.id

  use_instance_profile = (
    length(var.aws_iam_policy_arns) > 0 ||
    var.enable_cloudwatch_logs ||
    var.enable_ssm ||
    var.rundeck_admin_password_ssm_path != null
  )

  instance_id                = aws_instance.this.id
  log_group_name             = "/${var.name}/ec2"
  log_group_name_url_encoded = replace(local.log_group_name, "/", "$252F")
  partition                  = data.aws_partition.current.partition

  common_tags = merge(
    {
      Name      = var.name
      ManagedBy = "terraform"
      Module    = "terraform-aws-ec2-rundeck"
      OS        = "Rocky Linux 9"
    },
    var.tags
  )

  alarm_sns_arn = var.create_sns_topic ? (length(aws_sns_topic.alarms) > 0 ? aws_sns_topic.alarms[0].arn : null) : var.alarm_sns_topic_arn
}
