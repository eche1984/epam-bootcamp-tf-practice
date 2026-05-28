provider "aws" {
  region = var.aws_region
}

# Network Module
module "network" {
  source = "./modules/network"

  project_id       = var.project_id
  vpc_cidr         = var.vpc_cidr
  vpc_name         = var.vpc_name
  igw_name         = var.igw_name
  route_table_name = var.route_table_name
  public_subnets   = var.public_subnets
  common_tags      = var.common_tags
}

# Network Security Module
module "network_security" {
  source = "./modules/network_security"

  project_id           = var.project_id
  vpc_id               = module.network.vpc_id
  allowed_ip_ranges    = var.allowed_ip_ranges
  ssh_sg_name          = var.ssh_sg_name
  public_http_sg_name  = var.public_http_sg_name
  private_http_sg_name = var.private_http_sg_name
  common_tags          = var.common_tags
}

# Application Module
module "application" {
  source = "./modules/application"

  project_id                     = var.project_id
  vpc_id                         = module.network.vpc_id
  subnet_ids                     = module.network.public_subnet_ids_list
  ssh_security_group_id          = module.network_security.ssh_security_group_id
  private_http_security_group_id = module.network_security.private_http_security_group_id
  public_http_security_group_id  = module.network_security.public_http_security_group_id
  launch_template_name           = var.launch_template_name
  asg_name                       = var.asg_name
  load_balancer_name             = var.load_balancer_name
  target_group_name              = var.target_group_name
  instance_type                  = var.instance_type
  asg_capacity                   = var.asg_capacity
  common_tags                    = var.common_tags
}