resource "aws_vpc" "main" {
  cidr_block         = var.cidr_block # cidr block will be sent to env main.tf
  enable_dns_support = true
  tags = merge({
    Name = "${var.env}-vpc"
  },
    var.tags)  # this tag we are giving info in main.tfvars
}


# Local module for subnets

module "subnets" {
  source = "./subnets"

  for_each    = var.subnets
  cidr_block  = each.value["cidr_block"]
  subnet_name = each.key

  vpc_id = aws_vpc.main.id

  env  = var.env
  tags = var.tags
  az = var.az

}




