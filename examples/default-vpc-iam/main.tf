
module "rundeck" {
  source               = "../../"
  aws_vpc_id           = data.aws_vpc.default.id
  aws_subnet_id        = data.aws_subnet.default.id
  key_pair_name        = "rundeck-us-west-2"
  create_spot_instance = true
  aws_iam_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess",
    aws_iam_policy.rundeck.arn
  ]

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

resource "aws_iam_policy" "rundeck" {
  name        = "rundeck-io-policy"
  description = "Policy for EC2 Rundeck"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = [
        "s3:Get*",
        "s3:List*"
      ],
      Effect   = "Allow",
      Resource = "*"
      },
      {
        "Effect" : "Allow",
        "Action" : ["ec2:Describe*"],
        "Resource" : "*"
      }
    ]
  })
}
