# Target Groups
resource "aws_lb_target_group" "blue" {
  name        = "${var.project_id}-blue-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.main.id
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
    Name    = "${var.project_id}-blue-tg"
    Project = var.project_id
    Color   = "Blue"
  })
}

resource "aws_lb_target_group" "green" {
  name        = "${var.project_id}-green-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.main.id
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
    Name    = "${var.project_id}-green-tg"
    Project = var.project_id
    Color   = "Green"
  })
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = "${var.project_id}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.lb.id]
  subnets            = data.aws_subnets.public.ids

  tags = merge(var.common_tags, {
    Name    = "${var.project_id}-lb"
    Project = var.project_id
  })
}

# Listener with weighted routing
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"

    forward {
      target_group {
        arn    = aws_lb_target_group.blue.arn
        weight = var.blue_weight
      }

      target_group {
        arn    = aws_lb_target_group.green.arn
        weight = var.green_weight
      }

      stickiness {
        enabled  = false
        duration = 1
      }
    }
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_id}-listener"
  })
}