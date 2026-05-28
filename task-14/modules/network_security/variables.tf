variable "project_id" {
  description = "Project identifier for naming resources"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where security groups will be created"
  type        = string
}

variable "allowed_ip_ranges" {
  description = "List of IP ranges allowed to access SSH and HTTP"
  type        = list(string)
}

variable "public_http_sg_name" {
  description = "Name of the public HTTP security group"
  type        = string
}

variable "private_http_sg_name" {
  description = "Name of the private HTTP security group"
  type        = string
}

variable "ssh_sg_name" {
  description = "Name of the SSH security group"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}