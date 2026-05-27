# Discover VPC by name tag
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

# Discover public subnet by name tag
data "aws_subnet" "public" {
  filter {
    name   = "tag:Name"
    values = [var.public_subnet_name]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

# Discover security group by name tag
data "aws_security_group" "main" {
  filter {
    name   = "tag:Name"
    values = [var.security_group_name]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
}

# Discover Amazon Linux 2023 AMI
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