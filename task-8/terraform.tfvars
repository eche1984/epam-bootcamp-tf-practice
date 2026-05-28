aws_region                = "eu-west-1"
project_id                = "cmtr-d3wf0oa8"
launch_template_name      = "cmtr-d3wf0oa8-template"
asg_name                  = "cmtr-d3wf0oa8-asg"
load_balancer_name        = "cmtr-d3wf0oa8-loadbalancer"
target_group_name         = "cmtr-d3wf0oa8-tg"
key_pair_name             = "cmtr-d3wf0oa8-keypair"
iam_instance_profile_name = "cmtr-d3wf0oa8-instance_profile"
security_group_lb_name    = "cmtr-d3wf0oa8-sglb"
vpc_name                  = "cmtr-d3wf0oa8-vpc"

subnet_cidrs = {
  public_a_cidr  = "10.0.1.0/24"
  public_b_cidr  = "10.0.3.0/24"
  private_a_cidr = "10.0.2.0/24"
  private_b_cidr = "10.0.4.0/24"
}

instance_type = "t3.micro"

security_group_names = {
  ec2_sg  = "cmtr-d3wf0oa8-ec2_sg"
  http_sg = "cmtr-d3wf0oa8-http_sg"
}

metadata_options = {
  http_endpoint = "enabled"
  http_tokens   = "optional"
}

asg_capacity = {
  desired = 2
  min     = 1
  max     = 2
}

load_balancer_type     = "application"
load_balancer_internal = false
target_group_port      = 80
listener_port          = 80
listener_protocol      = "HTTP"

health_check_config = {
  enabled             = true
  healthy_threshold   = 2
  unhealthy_threshold = 2
  timeout             = 5
  interval            = 30
  path                = "/"
  protocol            = "HTTP"
  matcher             = "200"
}

common_tags = {
  Terraform = "true"
  Project   = "cmtr-d3wf0oa8"
}

user_data_message_template = "This message was generated on instance %s with the following IP: %s"