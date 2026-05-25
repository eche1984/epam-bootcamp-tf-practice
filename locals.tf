locals {
  public_subnets = {
    "a" = { cidr = "${var.public_subnet_cidr_1}", az_index = 0 }
    "b" = { cidr = "${var.public_subnet_cidr_2}", az_index = 1 }
    "c" = { cidr = "${var.public_subnet_cidr_3}", az_index = 2 }
  }
}