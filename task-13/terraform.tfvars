aws_region       = "eu-west-1"
project_id       = "cmtr-d3wf0oa8"
blue_weight      = 100
green_weight     = 0
instance_type    = "t3.micro"
desired_capacity = 1
min_size         = 1
max_size         = 2

common_tags = {
  Project   = "cmtr-d3wf0oa8"
  Terraform = "true"
}