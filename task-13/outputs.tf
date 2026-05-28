output "load_balancer_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "blue_target_group_arn" {
  description = "ARN of the Blue target group"
  value       = aws_lb_target_group.blue.arn
}

output "green_target_group_arn" {
  description = "ARN of the Green target group"
  value       = aws_lb_target_group.green.arn
}

output "traffic_distribution" {
  description = "Current traffic weight distribution"
  value = {
    blue_weight  = var.blue_weight
    green_weight = var.green_weight
  }
}

output "test_command" {
  description = "Command to test the load balancer"
  value       = "curl -s http://${aws_lb.main.dns_name} | grep -E '(Blue|Green) Environment'"
}

output "blue_asg_name" {
  description = "Name of the Blue Auto Scaling Group"
  value       = aws_autoscaling_group.blue.name
}

output "green_asg_name" {
  description = "Name of the Green Auto Scaling Group"
  value       = aws_autoscaling_group.green.name
}