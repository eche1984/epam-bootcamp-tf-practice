variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_prefix_name" {
  description = "Name of public subnet in eu-west-1a"
  type        = string
}

variable "public_subnet_cidr_1" {
  description = "CIDR block for public subnet in eu-west-1a"
  type        = string
}

variable "public_subnet_cidr_2" {
  description = "CIDR block for public subnet in eu-west-1b"
  type        = string
}

variable "public_subnet_cidr_3" {
  description = "CIDR block for public subnet in eu-west-1c"
  type        = string
}

variable "igw_name" {
  description = "Name of the Internet Gateway"
  type        = string
}

variable "route_table_name" {
  description = "Name of the route table"
  type        = string
}