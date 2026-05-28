aws_region = "eu-west-1"
project_id = "cmtr-d3wf0oa8"

vpc_cidr         = "10.10.0.0/16"
vpc_name         = "cmtr-d3wf0oa8-vpc"
igw_name         = "cmtr-d3wf0oa8-igw"
route_table_name = "cmtr-d3wf0oa8-rt"

public_subnets = {
  a = {
    name = "cmtr-d3wf0oa8-subnet-public-a"
    cidr = "10.10.1.0/24"
    az   = "eu-west-1a"
  }
  b = {
    name = "cmtr-d3wf0oa8-subnet-public-b"
    cidr = "10.10.3.0/24"
    az   = "eu-west-1b"
  }
  c = {
    name = "cmtr-d3wf0oa8-subnet-public-c"
    cidr = "10.10.5.0/24"
    az   = "eu-west-1c"
  }
}

ssh_sg_name          = "cmtr-d3wf0oa8-ssh-sg"
public_http_sg_name  = "cmtr-d3wf0oa8-public-http-sg"
private_http_sg_name = "cmtr-d3wf0oa8-private-http-sg"
launch_template_name = "cmtr-d3wf0oa8-template"
asg_name             = "cmtr-d3wf0oa8-asg"
load_balancer_name   = "cmtr-d3wf0oa8-lb"
target_group_name    = "cmtr-d3wf0oa8-tg"
instance_type        = "t3.micro"

asg_capacity = {
  desired = 2
  min     = 2
  max     = 2
}

common_tags = {
  Terraform = "true"
  Project   = "cmtr-d3wf0oa8"
}

allowed_ip_ranges = ["18.153.146.156/32", "200.61.172.129/32"]
