# AWS Region
variable "aws_region" {
  description = "AWS region where resources are located"
  type        = string
}

variable "project_id" {
  description = "Project identifier used for tagging"
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC to discover"
  type        = string
}

variable "public_subnet_name" {
  description = "The name of the public subnet to discover"
  type        = string
}

variable "security_group_name" {
  description = "The name of the security group to discover"
  type        = string
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to the EC2 instance"
  type        = map(string)
}