# Data source for Amazon Linux 2023 AMI
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

# Data sources for existing resources
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["cmtr-d3wf0oa8-vpc"]
  }
}

data "aws_subnet" "public_a" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  filter {
    name   = "cidr-block"
    values = ["10.0.1.0/24"]
  }
}

data "aws_subnet" "public_b" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  filter {
    name   = "cidr-block"
    values = ["10.0.3.0/24"]
  }
}

data "aws_subnet" "private_a" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  filter {
    name   = "cidr-block"
    values = ["10.0.2.0/24"]
  }
}

data "aws_subnet" "private_b" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  filter {
    name   = "cidr-block"
    values = ["10.0.4.0/24"]
  }
}

data "aws_security_group" "ec2_sg" {
  filter {
    name   = "tag:Name"
    values = ["cmtr-d3wf0oa8-ec2_sg"]
  }
}

data "aws_security_group" "http_sg" {
  filter {
    name   = "tag:Name"
    values = ["cmtr-d3wf0oa8-http_sg"]
  }
}

data "aws_security_group" "sglb" {
  filter {
    name   = "tag:Name"
    values = ["cmtr-d3wf0oa8-sglb"]
  }
}

data "aws_iam_instance_profile" "instance_profile" {
  name = "cmtr-d3wf0oa8-instance_profile"
}

data "aws_key_pair" "keypair" {
  key_name = "cmtr-d3wf0oa8-keypair"
}

# User data script
locals {
  user_data = <<-EOF
    #!/bin/bash

    sleep 60

    # Update system packages
    sudo dnf update -y
    
    # Install required packages
    sudo dnf install -y httpd jq
    
    # Enable and start web server
    sudo systemctl enable httpd
    sudo systemctl start httpd
    
    # Retrieve instance metadata using IMDSv2
    TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
    INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id)
    PRIVATE_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/local-ipv4)
    
    # Create index.html with instance information
    cat > /var/www/html/index.html << HTML
    <html>
    <head><title>EC2 Instance Info</title></head>
    <body>
    <h1>This message was generated on instance $INSTANCE_ID with the following IP: $PRIVATE_IP</h1>
    </body>
    </html>
    HTML
  EOF
}

# Launch Template
resource "aws_launch_template" "main" {
  name_prefix   = "cmtr-d3wf0oa8-template"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.micro"
  key_name      = data.aws_key_pair.keypair.key_name

  iam_instance_profile {
    name = data.aws_iam_instance_profile.instance_profile.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [
      data.aws_security_group.ec2_sg.id,
      data.aws_security_group.http_sg.id
    ]
    delete_on_termination = true
  }

  user_data = base64encode(local.user_data)

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Terraform = "true"
      Project   = "cmtr-d3wf0oa8"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Terraform = "true"
      Project   = "cmtr-d3wf0oa8"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Target Group for Load Balancer
resource "aws_lb_target_group" "main" {
  name     = "cmtr-d3wf0oa8-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
  }

  tags = {
    Terraform = "true"
    Project   = "cmtr-d3wf0oa8"
  }
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "cmtr-d3wf0oa8-loadbalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.sglb.id]
  subnets = [
    data.aws_subnet.public_a.id,
    data.aws_subnet.public_b.id
  ]

  tags = {
    Terraform = "true"
    Project   = "cmtr-d3wf0oa8"
  }
}

# Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  tags = {
    Terraform = "true"
    Project   = "cmtr-d3wf0oa8"
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "main" {
  name = "cmtr-d3wf0oa8-asg"
  vpc_zone_identifier = [
    data.aws_subnet.public_a.id,
    data.aws_subnet.public_b.id
  ]
  desired_capacity = 2
  min_size         = 1
  max_size         = 2

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  lifecycle {
    ignore_changes = [
      load_balancers,
      target_group_arns
    ]
  }

  tag {
    key                 = "Terraform"
    value               = "true"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = "cmtr-d3wf0oa8"
    propagate_at_launch = true
  }

  depends_on = [aws_lb_listener.http]
}

# Auto Scaling Group Attachment to Target Group
resource "aws_autoscaling_attachment" "main" {
  autoscaling_group_name = aws_autoscaling_group.main.name
  lb_target_group_arn    = aws_lb_target_group.main.arn
}