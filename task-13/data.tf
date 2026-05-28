# Data sources for existing resources
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["${var.project_id}-vpc"]
  }
}

data "aws_subnet" "public_1" {
  filter {
    name   = "tag:Name"
    values = ["${var.project_id}-public-subnet1"]
  }
}

data "aws_subnet" "public_2" {
  filter {
    name   = "tag:Name"
    values = ["${var.project_id}-public-subnet2"]
  }
}

data "aws_security_group" "ssh" {
  filter {
    name   = "tag:Name"
    values = ["${var.project_id}-sg-ssh"]
  }
}

data "aws_security_group" "http" {
  filter {
    name   = "tag:Name"
    values = ["${var.project_id}-sg-http"]
  }
}

data "aws_security_group" "lb" {
  filter {
    name   = "tag:Name"
    values = ["${var.project_id}-sg-lb"]
  }
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Public subnets list for ALB
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  filter {
    name   = "tag:Name"
    values = ["${var.project_id}-public-subnet1", "${var.project_id}-public-subnet2"]
  }
}