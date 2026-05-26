variable "aws_region" {
  description = "AWS region for the resources"
  type        = string
}

variable "project_id" {
  description = "Project identifier used for tagging"
  type        = string
}

variable "state_bucket" {
  description = "S3 bucket name that stores the remote state"
  type        = string
}

variable "state_key" {
  description = "S3 key path to the remote state file"
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
