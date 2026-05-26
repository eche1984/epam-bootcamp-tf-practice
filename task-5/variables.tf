variable "project_tag" {
  description = "Project tag value"
  type        = string
}

variable "allowed_ip_range" {
  description = "List of IP ranges allowed to access the infrastructure"
  type        = list(string)
}

variable "vpc_id" {
  description = "ID of the existing VPC"
  type        = string
}

variable "public_ec2_instance_id" {
  description = "ID of the public EC2 instance"
  type        = string
}

variable "private_ec2_instance_id" {
  description = "ID of the private EC2 instance"
  type        = string
}
