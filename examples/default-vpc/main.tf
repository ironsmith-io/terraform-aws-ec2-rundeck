
module "rundeck" {
  source               = "../../"
  aws_vpc_id           = data.aws_vpc.default.id
  aws_subnet_id        = data.aws_subnet.default.id
  key_pair_name        = "rundeck-us-west-2"
  create_spot_instance = true

  # OPTIONALS           = defaults
  # ip_allow_ssh        = ["0.0.0.0/0"]
  # ip_allow_https      = ["0.0.0.0/0"]
  # root_volume_size    = 8
  # root_encrypted      = false
  # instance_type       = "c5.large"
  # create_spot_instance = false
  # aws_iam_policy_arns = []
  # example useage
  #   aws_iam_policy_arns = [
  #     "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
  #     "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess",
  #     aws_iam_policy.rundeck.arn
  #   ]
  # rdeck_jvm_settings = null
  # example useage
  # rdeck_jvm_settings = "-Xmx2048m -Xms512m"

}

provider "aws" {
  region = "us-west-2"
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
