output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_id_list" {
  description = "The IDs of all public subnets"
  value = {
    for key, subnet in aws_subnet.public : key => subnet.id
  }
}

output "public_subnet_cidr_block_list" {
  description = "The CIDR blocks of all public subnets"
  value = {
    for key, subnet in aws_subnet.public : key => subnet.cidr_block
  }
}

output "public_subnet_az_list" {
  description = "The Availability Zones of all public subnets"
  value = {
    for key, subnet in aws_subnet.public : key => subnet.availability_zone
  }
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "routing_table_id" {
  description = "ID of the route table"
  value       = aws_route_table.public.id
}
