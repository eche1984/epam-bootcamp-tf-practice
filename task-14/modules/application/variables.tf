variable "project_id" {
  description = "Project identifier for naming resources"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where security groups will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the Auto Scaling Group"
  type        = list(string)
}

variable "ssh_security_group_id" {
  description = "ID of the SSH security group"
  type        = string
}

variable "private_http_security_group_id" {
  description = "ID of the private HTTP security group"
  type        = string
}

variable "public_http_security_group_id" {
  description = "ID of the public HTTP security group (for load balancer)"
  type        = string
}

variable "launch_template_name" {
  description = "Name of the launch template"
  type        = string
}

variable "asg_name" {
  description = "Name of the Auto Scaling Group"
  type        = string
}

variable "load_balancer_name" {
  description = "Name of the Application Load Balancer"
  type        = string
}

variable "target_group_name" {
  description = "Name of the target group"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "asg_capacity" {
  description = "Capacity settings for the Auto Scaling Group"
  type = object({
    desired = number
    min     = number
    max     = number
  })
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = null # Will use data source if not provided
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}