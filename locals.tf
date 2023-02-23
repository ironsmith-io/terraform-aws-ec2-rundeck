
locals {
  common_tags = {
    Name    = "Rundeck"
    app     = "rundeck"
    role    = "app"
    ver     = "0.0.1"
    contact = "hello@rundeck.io"
    env     = "dev"
    prov    = "terraform"
  }

  use_instance_profile = length(var.aws_iam_policy_arns) > 0
  rdeck_jvm_settings   = var.rdeck_jvm_settings

}
