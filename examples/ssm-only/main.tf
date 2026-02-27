# SSM-only Rundeck deployment
# No SSH access - connect via AWS Systems Manager Session Manager
# No EC2 key pair required

provider "aws" {
  region = "us-west-2"
}

module "rundeck" {
  source = "../../"

  subnet_id = var.subnet_id

  # SSM-only: no SSH, no key pair
  enable_ssm = true
  enable_ssh = false

  # Web UI access
  ip_allow_https = var.ip_allow_https
}
