# Data source for existing VPC
data "aws_vpc" "existing" {
  filter {
    name   = "tag:Name"
    values = ["cmtr-d3wf0oa8-vpc"]
  }
}

# Data source for existing public subnets
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*public*"]
  }
}

# Get the first public subnet (or use specific one)
data "aws_subnet" "public" {
  id = data.aws_subnets.public.ids[0]
}

# Data source for existing security group
data "aws_security_group" "existing" {
  filter {
    name   = "tag:Name"
    values = ["cmtr-d3wf0oa8-sg"]
  }
}

# Data source for latest Amazon Linux 2023 AMI
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

# EC2 Instance
resource "aws_instance" "cmtr-d3wf0oa8-ec2" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = "t3.micro"
  key_name                    = aws_key_pair.cmtr-d3wf0oa8-keypair.key_name
  subnet_id                   = data.aws_subnet.public.id
  vpc_security_group_ids      = [data.aws_security_group.existing.id]
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    echo "Amazon Linux 2023 EC2 instance running" > /var/log/user-data.log
  EOF

  tags = {
    Name    = "cmtr-d3wf0oa8-ec2"
    Project = var.project_tag
    ID      = var.id_tag
  }
}
