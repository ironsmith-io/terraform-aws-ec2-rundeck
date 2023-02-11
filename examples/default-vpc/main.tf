provider "aws" {
  region = "us-west-2"
}

module "rundeck" {
  source        = "../../"
  aws_vpc_id    = data.aws_vpc.default.id
  aws_subnet_id = data.aws_subnet.default.id
  key_pair_name = "rundeck-us-west-2"

  # OPTIONALS        = default
  # ip_allow_ssh     = ["0.0.0.0/0"]
  # ip_allow_https   = ["0.0.0.0/0"]
  # root_volume_size = 20
}

data "aws_vpc" "default" {
  default = true
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_subnet" "default" {
  availability_zone = data.aws_availability_zones.available.names[0]
  vpc_id            = data.aws_vpc.default.id
}

output "server_url" {
  value       = module.rundeck.server_url
  description = "HTTPS endpoint of Rundeck host"
}
