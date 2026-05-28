# Data source for Amazon Linux 2023 AMI (if ami_id not provided)
data "aws_ami" "amazon_linux_2023" {
  count = var.ami_id == null ? 1 : 0

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

locals {
  final_ami_id = var.ami_id != null ? var.ami_id : data.aws_ami.amazon_linux_2023[0].id

  user_data = <<-EOF
    #!/bin/bash
    sudo dnf update -y
    sudo dnf install -y httpd
    sudo systemctl enable httpd
    sudo systemctl start httpd
    
    COMPUTE_MACHINE_UUID=$(cat /sys/devices/virtual/dmi/id/product_uuid | tr '[:upper:]' '[:lower:]')
    TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
    COMPUTE_INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $${TOKEN}" http://169.254.169.254/latest/meta-data/instance-id)
    
    cat > /var/www/html/index.html << HTML
    <!DOCTYPE html>
    <html>
    <head>
      <title>Instance Information</title>
      <style>
        body { font-family: Arial, sans-serif; text-align: center; padding: 50px; background-color: #f0f0f0; }
        h1 { color: #333; }
        .info { background-color: white; padding: 20px; border-radius: 10px; margin-top: 20px; }
      </style>
    </head>
    <body>
      <h1>Welcome to the Application</h1>
      <div class="info">
        <p>This message was generated on instance <strong>$${COMPUTE_INSTANCE_ID}</strong> with the following UUID <strong>$${COMPUTE_MACHINE_UUID}</strong></p>
      </div>
    </body>
    </html>
    HTML
  EOF
}

# Target Group
resource "aws_lb_target_group" "main" {
  name        = var.target_group_name
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
  }

  tags = merge(var.common_tags, {
    Name = var.target_group_name
  })
}

# Launch Template
resource "aws_launch_template" "main" {
  name_prefix   = "${var.launch_template_name}-"
  image_id      = local.final_ami_id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [
      var.ssh_security_group_id,
      var.private_http_security_group_id
    ]
    delete_on_termination = true
  }

  user_data = base64encode(local.user_data)

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, {
      Name = "${var.project_id}-instance"
    })
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "main" {
  name                = var.asg_name
  vpc_zone_identifier = var.subnet_ids
  desired_capacity    = var.asg_capacity.desired
  min_size            = var.asg_capacity.min
  max_size            = var.asg_capacity.max
  health_check_type   = "ELB"
  health_check_grace_period = 60

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  lifecycle {
    ignore_changes = [load_balancers, target_group_arns]
  }

  tag {
    key                 = "Name"
    value               = "${var.project_id}-asg"
    propagate_at_launch = true
  }

  
  dynamic "tag" {
    for_each = var.common_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true      
    }
  }
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = var.load_balancer_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.public_http_security_group_id]
  subnets            = var.subnet_ids

  tags = merge(var.common_tags, {
    Name = var.load_balancer_name
  })
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

  tags = merge(var.common_tags, {
    Name = "${var.load_balancer_name}-listener"
  })
}

# Auto Scaling Group Attachment
resource "aws_autoscaling_attachment" "main" {
  autoscaling_group_name = aws_autoscaling_group.main.name
  lb_target_group_arn    = aws_lb_target_group.main.arn
}