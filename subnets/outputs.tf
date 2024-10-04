output "subnet_ids" {
  value = aws_subnet.main.*.id
}

# route table is getting created inside the subnet and we need to get the information from the route table so we are using the outputs

# We will be sending the output to the main module

output "route_table_ids" {
  value = aws_route_table.route_table.id
}