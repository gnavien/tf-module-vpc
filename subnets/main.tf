resource "aws_subnet" "main" {
  count             = length(var.cidr_block)
  vpc_id            = var.vpc_id
  cidr_block        = element(var.cidr_block, count.index)
  availability_zone = element(var.az, count.index)

  tags = merge({
    Name = "${var.env}-${var.subnet_name}-subnet"
  },
    var.tags)
}

resource "aws_route_table" "route_table" {
  vpc_id = var.vpc_id

  tags = merge({
    Name = "${var.env}-${var.subnet_name}-route_table"
  },
    var.tags)
}

# We need to add a route table association for each subnet

resource "aws_route_table_association" "association" {
  count      = length(aws_subnet.main)
  subnet_id   = aws_subnet.main[count.index].id
  route_table_id = aws_route_table.route_table.id
}
