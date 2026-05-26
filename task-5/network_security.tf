# SSH Security Group
resource "aws_security_group" "ssh_sg" {
  name        = "${var.project_tag}-ssh-sg"
  description = "Security group for SSH access"
  vpc_id      = var.vpc_id

  tags = {
    Project = var.project_tag
  }
}

# SSH Ingress Rules
resource "aws_security_group_rule" "ssh_ingress" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.allowed_ip_range
  security_group_id = aws_security_group.ssh_sg.id
  description       = "Allow SSH from allowed IP ranges"
}

resource "aws_security_group_rule" "ssh_icmp_ingress" {
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = var.allowed_ip_range
  security_group_id = aws_security_group.ssh_sg.id
  description       = "Allow ICMP from allowed IP ranges"
}

# Public HTTP Security Group
resource "aws_security_group" "public_http_sg" {
  name        = "${var.project_tag}-public-http-sg"
  description = "Security group for public HTTP access"
  vpc_id      = var.vpc_id

  tags = {
    Project = var.project_tag
  }
}

# Public HTTP Ingress Rules
resource "aws_security_group_rule" "http_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = var.allowed_ip_range
  security_group_id = aws_security_group.public_http_sg.id
  description       = "Allow HTTP from allowed IP ranges"
}

resource "aws_security_group_rule" "public_http_icmp_ingress" {
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = var.allowed_ip_range
  security_group_id = aws_security_group.public_http_sg.id
  description       = "Allow ICMP from allowed IP ranges"
}

# Private HTTP Security Group
resource "aws_security_group" "private_http_sg" {
  name        = "${var.project_tag}-private-http-sg"
  description = "Security group for private HTTP access"
  vpc_id      = var.vpc_id

  tags = {
    Project = var.project_tag
  }
}

# Private HTTP Ingress Rules (using source_security_group_id)
resource "aws_security_group_rule" "private_http_ingress" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.public_http_sg.id
  security_group_id        = aws_security_group.private_http_sg.id
  description              = "Allow HTTP on port 8080 from public HTTP security group"
}

resource "aws_security_group_rule" "private_http_icmp_ingress" {
  type                     = "ingress"
  from_port                = -1
  to_port                  = -1
  protocol                 = "icmp"
  source_security_group_id = aws_security_group.public_http_sg.id
  security_group_id        = aws_security_group.private_http_sg.id
  description              = "Allow ICMP from public HTTP security group"
}

# Egress rules for all security groups (allow all outbound traffic)
resource "aws_security_group_rule" "ssh_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ssh_sg.id
  description       = "Allow all outbound traffic"
}

resource "aws_security_group_rule" "public_http_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public_http_sg.id
  description       = "Allow all outbound traffic"
}

resource "aws_security_group_rule" "private_http_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.private_http_sg.id
  description       = "Allow all outbound traffic"
}

# Attach security groups to existing instances
data "aws_instance" "public" {
  instance_id = var.public_ec2_instance_id
}

data "aws_instance" "private" {
  instance_id = var.private_ec2_instance_id
}

data "aws_network_interface" "public_eni" {
  id = data.aws_instance.public.network_interface_id
}

data "aws_network_interface" "private_eni" {
  id = data.aws_instance.private.network_interface_id
}

# Attach SSH and Public HTTP security groups to public instance
resource "aws_network_interface_sg_attachment" "public_ssh" {
  security_group_id    = aws_security_group.ssh_sg.id
  network_interface_id = data.aws_network_interface.public_eni.id
}

resource "aws_network_interface_sg_attachment" "public_http" {
  security_group_id    = aws_security_group.public_http_sg.id
  network_interface_id = data.aws_network_interface.public_eni.id
}

# Attach SSH and Private HTTP security groups to private instance
resource "aws_network_interface_sg_attachment" "private_ssh" {
  security_group_id    = aws_security_group.ssh_sg.id
  network_interface_id = data.aws_network_interface.private_eni.id
}

resource "aws_network_interface_sg_attachment" "private_http" {
  security_group_id    = aws_security_group.private_http_sg.id
  network_interface_id = data.aws_network_interface.private_eni.id
}