aws_region = "eu-west-1"
project_id = "cmtr-d3wf0oa8"

vpc_name            = "cmtr-d3wf0oa8-vpc"
public_subnet_name  = "cmtr-d3wf0oa8-public-subnet-1"
security_group_name = "cmtr-d3wf0oa8-sg"
instance_name       = "cmtr-d3wf0oa8-instance"
instance_type       = "t3.micro"

common_tags = {
  Terraform = "true"
  Project   = "cmtr-d3wf0oa8"
}