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
    values = [var.vpc_name]
  }
}

data "aws_subnet" "public_a" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  filter {
    name   = "cidr-block"
    values = [var.subnet_cidrs.public_a_cidr]
  }
}

data "aws_subnet" "public_b" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  filter {
    name   = "cidr-block"
    values = [var.subnet_cidrs.public_b_cidr]
  }
}

data "aws_subnet" "private_a" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  filter {
    name   = "cidr-block"
    values = [var.subnet_cidrs.private_a_cidr]
  }
}

data "aws_subnet" "private_b" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }
  filter {
    name   = "cidr-block"
    values = [var.subnet_cidrs.private_b_cidr]
  }
}

data "aws_security_group" "ec2_sg" {
  filter {
    name   = "tag:Name"
    values = [var.security_group_names.ec2_sg]
  }
}

data "aws_security_group" "http_sg" {
  filter {
    name   = "tag:Name"
    values = [var.security_group_names.http_sg]
  }
}

data "aws_security_group" "sglb" {
  filter {
    name   = "tag:Name"
    values = [var.security_group_lb_name]
  }
}

data "aws_iam_instance_profile" "instance_profile" {
  name = var.iam_instance_profile_name
}

data "aws_key_pair" "keypair" {
  key_name = var.key_pair_name
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
  name_prefix   = "${var.launch_template_name}-"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type
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
    http_endpoint = var.metadata_options.http_endpoint
    http_tokens   = var.metadata_options.http_tokens
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, {
      Name = "${var.project_id}-ec2"
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags          = var.common_tags
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Target Group for Load Balancer
resource "aws_lb_target_group" "main" {
  name     = var.target_group_name
  port     = var.target_group_port
  protocol = var.target_group_protocol
  vpc_id   = data.aws_vpc.main.id

  load_balancing_algorithm_type = "round_robin"

  stickiness {
    type    = "lb_cookie"
    enabled = false
  }

  health_check {
    enabled             = var.health_check_config.enabled
    healthy_threshold   = var.health_check_config.healthy_threshold
    unhealthy_threshold = var.health_check_config.unhealthy_threshold
    timeout             = var.health_check_config.timeout
    interval            = var.health_check_config.interval
    path                = var.health_check_config.path
    protocol            = var.health_check_config.protocol
    matcher             = var.health_check_config.matcher
  }

  tags = var.common_tags
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = var.load_balancer_name
  internal           = var.load_balancer_internal
  load_balancer_type = var.load_balancer_type
  security_groups    = [data.aws_security_group.sglb.id]
  subnets = [
    data.aws_subnet.public_a.id,
    data.aws_subnet.public_b.id
  ]

  tags = var.common_tags
}

# Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  tags = var.common_tags
}

# Auto Scaling Group
resource "aws_autoscaling_group" "main" {
  name = var.asg_name
  vpc_zone_identifier = [
    data.aws_subnet.public_a.id,
    data.aws_subnet.public_b.id
  ]

  desired_capacity = var.asg_capacity.desired
  min_size         = var.asg_capacity.min
  max_size         = var.asg_capacity.max

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  lifecycle {
    ignore_changes = [load_balancers, target_group_arns]
  }

  dynamic "tag" {
    for_each = var.common_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  depends_on = [aws_lb_listener.http]
}

# Auto Scaling Group Attachment to Target Group
resource "aws_autoscaling_attachment" "main" {
  autoscaling_group_name = aws_autoscaling_group.main.name
  lb_target_group_arn    = aws_lb_target_group.main.arn
}