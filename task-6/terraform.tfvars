project_tag = "cmtr-d3wf0oa8"
aws_region = "eu-west-1"

vpc_name = "cmtr-d3wf0oa8-01-vpc"
vpc_cidr_block = "10.10.0.0/16"

public_subnets = {
  a = {
    name = "cmtr-d3wf0oa8-01-subnet-public-a"
    cidr = "10.10.1.0/24"
    az   = "eu-west-1a"
  }
  b = {
    name = "cmtr-d3wf0oa8-01-subnet-public-b"
    cidr = "10.10.3.0/24"
    az   = "eu-west-1b"
  }
  c = {
    name = "cmtr-d3wf0oa8-01-subnet-public-c"
    cidr = "10.10.5.0/24"
    az   = "eu-west-1c"
  }
}

igw_name         = "cmtr-d3wf0oa8-igw"
route_table_name = "cmtr-d3wf0oa8-01-rt"

common_tags = {
  Project = "cmtr-d3wf0oa8"
  ManagedBy   = "Terraform"
}