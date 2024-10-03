#resource "aws_vpc" "main" {
#  cidr_block         = var.cidr_block # cidr block will be sent to env main.tf
#  enable_dns_support = true
#  tags = merge({
#    Name = "${var.env}-vpc"
#  },
#    var.tags)  # this tag we are giving info in main.tfvars
#}

# Local module for subnets

module "subnets" {
  source = "./subnets"

  for_each    = var.subnets
  cidr_block  = each.value["cidr_block"]
  subnet_name = each.key

  vpc_id = aws_vpc.main.id

  env  = var.env
  tags = var.tags
#  az   = var.az
}
#
#
## 1st task is to create a AWS VPC peer connection
#
#
#
#resource "aws_vpc_peering_connection" "peer" {
#  peer_vpc_id   = aws_vpc.main.id
#  vpc_id        = var.default_vpc_id
#  auto_accept   = true  # If we dont give auto accept as true peering connection will be in pending state
#
#}

resource "aws_vpc" "main" {
  cidr_block         = var.cidr_block # cidr block will be sent to env main.tf
  enable_dns_support = true
  tags = merge({
    Name = "${var.env}-vpc"
  },
    var.tags)  # this tag we are giving info in main.tfvars
}


