variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "project_id" {
  description = "Project identifier for naming and tagging"
  type        = string
}

variable "blue_weight" {
  description = "Traffic weight for the Blue target group (0-100)"
  type        = number
}

variable "green_weight" {
  description = "Traffic weight for the Green target group (0-100)"
  type        = number
}

variable "instance_type" {
  description = "EC2 instance type for both environments"
  type        = string
}

variable "desired_capacity" {
  description = "Desired number of instances per Auto Scaling Group"
  type        = number
}

variable "min_size" {
  description = "Minimum number of instances per Auto Scaling Group"
  type        = number
}

variable "max_size" {
  description = "Maximum number of instances per Auto Scaling Group"
  type        = number
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}