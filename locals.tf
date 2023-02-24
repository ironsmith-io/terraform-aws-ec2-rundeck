
locals {
  use_instance_profile = length(var.aws_iam_policy_arns) > 0
  rdeck_jvm_settings   = var.rdeck_jvm_settings == null ? "" : var.rdeck_jvm_settings
}
