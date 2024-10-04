resource "aws_vpc" "main" {
  cidr_block         = var.cidr_block
  enable_dns_support = true
  tags = merge({
    Name = "${var.env}-vpc"
  },
    var.tags)
}

module "subnets" {
  source = "./subnets"

  for_each    = var.subnets
  cidr_block  = each.value["cidr_block"]
  subnet_name = each.key

  vpc_id = aws_vpc.main.id

  env  = var.env
  tags = var.tags
  az   = var.az
}

resource "aws_vpc_peering_connection" "peer" {
  peer_vpc_id = aws_vpc.main.id
  vpc_id      = var.default_vpc_id
  auto_accept = true
  tags = merge({
    Name = "${var.env}-vpc-peering-connection"
  },
    var.tags)
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge({
    Name = "${var.env}-igw"
  },
    var.tags)
}

resource "aws_route" "igw" {
  route_table_id        = module.subnets["public"].route_table_ids # we need to attach the route table only for the public
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id # In the above we have created IGW, while adding IGW use the aws route for the public
}

# We are creating a NAT gateway for the public, the mandatory needed is eip (elastic IP), we can check in terraform how to create aws_eip

resource "aws_eip" "ngw" {
  domain   = "vpc"
}


resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.ngw.id
  subnet_id     = lookup(lookup(module.subnets, "public", null), "subnet_ids", null)[0]

  tags = merge({
    Name = "${var.env}-ngw"
  },
    var.tags)

}

# We need to create a new route to the NAT gateway for the other services like web, app and DB

resource "aws_route" "route_ngw" {
  count      = length(local.private_route_table_ids)
  #wanted to pick one route table at a time so the below code
  route_table_id = element(local.private_route_table_ids, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.ngw.id
}

# We need to add one more route table to add all the subnets and peering connection to the route table

resource "aws_route" "peer-route" {
  count      = length(local.all_route_table_ids)
  #wanted to pick one route table at a time so the below code
  route_table_id = element(local.all_route_table_ids, count.index)
  destination_cidr_block = "172.31.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id # This way you can add peering connection to all the route tables
}

# We need to add an entry to default vpc for route tables. We have to copy the default route table from the
# default vpc default route table ID. This input will be given in main.tfvars


resource "aws_route" "default_vpc_route" {
  route_table_id            = var.default_rt_table
  destination_cidr_block    = var.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id # This way you can add peering connection to all the route tables
}
