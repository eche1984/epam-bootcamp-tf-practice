# AWS Region
variable "aws_region" {
  description = "AWS region where all resources will be created"
  type        = string
}

# Project configuration
variable "project_id" {
  description = "Project identifier used for naming resources and tagging"
  type        = string
}

# Common tags
variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
}

# Launch Template configuration
variable "launch_template_name" {
  description = "Name prefix for the launch template"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the Auto Scaling Group"
  type        = string
}

variable "key_pair_name" {
  description = "Name of the existing key pair for SSH access"
  type        = string
}

variable "iam_instance_profile_name" {
  description = "Name of the existing IAM instance profile for EC2 instances"
  type        = string
}

variable "security_group_names" {
  description = "Names of existing security groups to attach to EC2 instances"
  type        = map(string)
}

variable "metadata_options" {
  description = "Metadata options for EC2 instances"
  type = object({
    http_endpoint = string
    http_tokens   = string
  })
}

# Auto Scaling Group configuration
variable "asg_name" {
  description = "Name of the Auto Scaling Group"
  type        = string
}

variable "asg_capacity" {
  description = "Capacity settings for the Auto Scaling Group"
  type = object({
    desired = number
    min     = number
    max     = number
  })
}

# Load Balancer configuration
variable "load_balancer_name" {
  description = "Name of the Application Load Balancer"
  type        = string
}

variable "load_balancer_type" {
  description = "Type of load balancer (application, network, or gateway)"
  type        = string
}

variable "load_balancer_internal" {
  description = "Whether the load balancer is internal (true) or internet-facing (false)"
  type        = bool
}

variable "security_group_lb_name" {
  description = "Name of the existing security group for the load balancer"
  type        = string
}

# Target Group configuration
variable "target_group_name" {
  description = "Name of the target group for the load balancer"
  type        = string
}

variable "target_group_port" {
  description = "Port on which targets receive traffic"
  type        = number
}

variable "target_group_protocol" {
  description = "Protocol to use for routing traffic to targets"
  type        = string
  default     = "HTTP"
}

variable "health_check_config" {
  description = "Health check configuration for the target group"
  type = object({
    enabled             = bool
    healthy_threshold   = number
    unhealthy_threshold = number
    timeout             = number
    interval            = number
    path                = string
    protocol            = string
    matcher             = string
  })
}

# Listener configuration
variable "listener_port" {
  description = "Port for the load balancer listener"
  type        = number
}

variable "listener_protocol" {
  description = "Protocol for the load balancer listener"
  type        = string
}

# Subnet configuration
variable "subnet_cidrs" {
  description = "CIDR blocks for identifying public and private subnets"
  type = object({
    public_a_cidr  = string
    public_b_cidr  = string
    private_a_cidr = string
    private_b_cidr = string
  })
}

# VPC configuration
variable "vpc_name" {
  description = "Name of the existing VPC"
  type        = string
}

# User data script template variables
variable "user_data_message_template" {
  description = "Template for the user data message displayed on the web page"
  type        = string
}
