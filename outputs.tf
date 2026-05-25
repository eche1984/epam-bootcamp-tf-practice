output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "Map of public subnet IDs by AZ key"
  value = {
    for key, subnet in aws_subnet.public : key => subnet.id
  }
}

output "public_subnet_availability_zones" {
  description = "Availability zones of public subnets"
  value = {
    for key, subnet in aws_subnet.public : key => subnet.availability_zone
  }
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}