# tf-module-vpc

# Steps to create a VPC and network connection for the project
1. Create a VPC
2. public subnet and private subnet
3. add route table one for private and public
4. Create Internet gateway, and add that to public route table
5. Create one elastic IP.
6. Create a NAT gateway and add that to private route table
7. create peering connection
8. add peering connection routes to public and private subnets, also add that to default route table.