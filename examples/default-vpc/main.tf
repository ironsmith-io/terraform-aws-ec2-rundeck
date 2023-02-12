
module "rundeck" {
  source        = "../../"
  aws_vpc_id    = data.aws_vpc.default.id
  aws_subnet_id = data.aws_subnet.default.id
  key_pair_name = "rundeck-us-west-2"

  # OPTIONALS           = defaults
  # ip_allow_ssh        = ["0.0.0.0/0"]
  # ip_allow_https      = ["0.0.0.0/0"]
  # root_volume_size    = 8
  # root_encrypted      = false
  # instance_type       = "c5.large"
  # aws_iam_policy_arns = []

  # example useage
  #   aws_iam_policy_arns = [
  #     "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
  #     "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess",
  #     aws_iam_policy.rundeck.arn
  #   ]

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

# resource "aws_iam_policy" "rundeck" {
#   name        = "rundeck-io-policy"
#   description = "Policy for EC2 Rundeck"
#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Action = [
#         "s3:Get*",
#         "s3:List*"
#       ],
#       Effect   = "Allow",
#       Resource = "*"
#       },
#       {
#         "Effect" : "Allow",
#         "Action" : ["ec2:Describe*"],
#         "Resource" : "*"
#       }
#     ]
#   })
# }

output "server_url" {
  value       = module.rundeck.server_url
  description = "HTTPS endpoint of Rundeck host"
}
