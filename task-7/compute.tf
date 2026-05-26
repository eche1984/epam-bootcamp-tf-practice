data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# EC2 instance in the public subnet using remote state outputs
resource "aws_instance" "main" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.instance_type
  subnet_id                   = data.terraform_remote_state.base_infra.outputs.public_subnet_id
  vpc_security_group_ids      = [data.terraform_remote_state.base_infra.outputs.security_group_id]
  associate_public_ip_address = true

  tags = {
    Name      = var.instance_name
    Terraform = "true"
    Project   = var.project_id
  }

  # Optional: Add user data for basic configuration
  user_data = <<-EOF
    #!/bin/bash
    sudo dnf update -y
    sudo dnf install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "Hello from Terraform remote state EC2 instance" > /var/www/html/index.html
  EOF
}