# Blue Launch Template
resource "aws_launch_template" "blue" {
  name_prefix   = "${var.project_id}-blue-template"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [
      data.aws_security_group.ssh.id,
      data.aws_security_group.http.id
    ]
    delete_on_termination = true
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    sudo dnf update -y
    sudo dnf install -y httpd
    sudo systemctl enable httpd
    sudo systemctl start httpd
    
    cat > /var/www/html/index.html << HTML
    <!DOCTYPE html>
    <html>
    <head>
      <title>Blue Environment</title>
      <style>
        body { background-color: #e3f2fd; font-family: Arial; text-align: center; padding: 50px; }
        h1 { color: #0d47a1; }
      </style>
    </head>
    <body>
      <h1>🔵 Blue Environment</h1>
      <p>This request was served by the Blue deployment</p>
      <p>Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>
    </body>
    </html>
    HTML
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, {
      Name    = "${var.project_id}-blue-instance"
      Project = var.project_id
      Color   = "Blue"
    })
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Green Launch Template
resource "aws_launch_template" "green" {
  name_prefix   = "${var.project_id}-green-template"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [
      data.aws_security_group.ssh.id,
      data.aws_security_group.http.id
    ]
    delete_on_termination = true
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    sudo dnf update -y
    sudo dnf install -y httpd
    sudo systemctl enable httpd
    sudo systemctl start httpd
    
    cat > /var/www/html/index.html << HTML
    <!DOCTYPE html>
    <html>
    <head>
      <title>Green Environment</title>
      <style>
        body { background-color: #e8f5e9; font-family: Arial; text-align: center; padding: 50px; }
        h1 { color: #1b5e20; }
      </style>
    </head>
    <body>
      <h1>🟢 Green Environment</h1>
      <p>This request was served by the Green deployment</p>
      <p>Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>
    </body>
    </html>
    HTML
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, {
      Name    = "${var.project_id}-green-instance"
      Project = var.project_id
      Color   = "Green"
    })
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Blue Auto Scaling Group
resource "aws_autoscaling_group" "blue" {
  name                      = "${var.project_id}-blue-asg"
  vpc_zone_identifier       = data.aws_subnets.public.ids
  desired_capacity          = var.desired_capacity
  min_size                  = var.min_size
  max_size                  = var.max_size
  health_check_type         = "ELB"
  health_check_grace_period = 60

  launch_template {
    id      = aws_launch_template.blue.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.blue.arn]

  tag {
    key                 = "Name"
    value               = "${var.project_id}-blue-asg"
    propagate_at_launch = true
  }
  tag {
    key                 = "Project"
    value               = var.project_id
    propagate_at_launch = true
  }
  tag {
    key                 = "Color"
    value               = "Blue"
    propagate_at_launch = true
  }
  tag {
    key                 = "Terraform"
    value               = "true"
    propagate_at_launch = true
  }

  depends_on = [aws_lb_listener.http]
}

# Green Auto Scaling Group
resource "aws_autoscaling_group" "green" {
  name                      = "${var.project_id}-green-asg"
  vpc_zone_identifier       = data.aws_subnets.public.ids
  desired_capacity          = var.desired_capacity
  min_size                  = var.min_size
  max_size                  = var.max_size
  health_check_type         = "ELB"
  health_check_grace_period = 60

  launch_template {
    id      = aws_launch_template.green.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.green.arn]

  tag {
    key                 = "Name"
    value               = "${var.project_id}-green-asg"
    propagate_at_launch = true
  }
  tag {
    key                 = "Project"
    value               = var.project_id
    propagate_at_launch = true
  }
  tag {
    key                 = "Color"
    value               = "Green"
    propagate_at_launch = true
  }
  tag {
    key                 = "Terraform"
    value               = "true"
    propagate_at_launch = true
  }

  depends_on = [aws_lb_listener.http]
}