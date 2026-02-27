# Minimal Rundeck deployment
# Uses all default settings - SSH access only, no SSM

provider "aws" {
  region = "us-west-2"
}

module "rundeck" {
  source = "../../"

  # Required variables
  subnet_id      = var.subnet_id
  key_pair_name  = var.key_pair_name
  ip_allow_ssh   = var.ip_allow_ssh
  ip_allow_https = var.ip_allow_https
}
