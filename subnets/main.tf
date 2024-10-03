#resource "aws_subnet" "main" {
#  count             = length(var.cidr_block)
#  vpc_id            = var.vpc_id
#  cidr_block        = element(var.cidr_block, count.index)
#  availability_zone = element(var.az, count.index) # we have declared value az in variables to pick az as us-east-1a, and us-east-1b
#
#  tags = merge({
#    Name = "${var.env}-${var.subnet_name}-subnet"
#  },
#    var.tags)
#}