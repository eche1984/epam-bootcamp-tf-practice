# SSH Security Group
resource "aws_security_group" "ssh" {
  name        = var.ssh_sg_name
  description = "Security group for SSH access"
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, {
    Name = var.ssh_sg_name
  })
}

# SSH Ingress Rules
resource "aws_security_group_rule" "ssh_ingress" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.allowed_ip_ranges
  security_group_id = aws_security_group.ssh.id
  description       = "Allow SSH from allowed IP ranges"
}

/*
resource "aws_security_group_rule" "ssh_icmp_ingress" {
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = var.allowed_ip_ranges
  security_group_id = aws_security_group.ssh.id
  description       = "Allow ICMP from allowed IP ranges"
}
*/

# Public HTTP Security Group
resource "aws_security_group" "public_http" {
  name        = var.public_http_sg_name
  description = "Security group for public HTTP access"
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, {
    Name = var.public_http_sg_name
  })
}

# Public HTTP Ingress Rules
resource "aws_security_group_rule" "http_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = var.allowed_ip_ranges
  security_group_id = aws_security_group.public_http.id
  description       = "Allow HTTP from allowed IP ranges"
}

/*
resource "aws_security_group_rule" "public_http_icmp_ingress" {
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = var.allowed_ip_ranges
  security_group_id = aws_security_group.public_http.id
  description       = "Allow ICMP from allowed IP ranges"
}
*/

# Private HTTP Security Group
resource "aws_security_group" "private_http" {
  name        = var.private_http_sg_name
  description = "Security group for private HTTP access"
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, {
    Name = var.private_http_sg_name
  })
}

# Private HTTP Ingress Rules (from public HTTP SG)
resource "aws_security_group_rule" "private_http_ingress" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.public_http.id
  security_group_id        = aws_security_group.private_http.id
  description              = "Allow HTTP from public HTTP security group"
}

/*
resource "aws_security_group_rule" "private_http_icmp_ingress" {
  type                     = "ingress"
  from_port                = -1
  to_port                  = -1
  protocol                 = "icmp"
  source_security_group_id = aws_security_group.public_http.id
  security_group_id        = aws_security_group.private_http.id
  description              = "Allow ICMP from public HTTP security group"
}
*/

# Egress rules for all security groups
resource "aws_security_group_rule" "ssh_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ssh.id
}

resource "aws_security_group_rule" "public_http_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public_http.id
}

resource "aws_security_group_rule" "private_http_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.private_http.id
}