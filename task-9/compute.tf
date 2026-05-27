# EC2 instance using discovered resources
resource "aws_instance" "main" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.instance_type
  subnet_id                   = data.aws_subnet.public.id
  vpc_security_group_ids      = [data.aws_security_group.main.id]
  associate_public_ip_address = true

  tags = merge(var.common_tags, {
    Name    = var.instance_name
    Project = var.project_id
  })

  user_data = <<-EOF
    #!/bin/bash
    sudo dnf update -y
    sudo dnf install -y httpd
    sudo systemctl enable httpd
    sudo systemctl start httpd
    echo "Hello from ${var.instance_name}" > /var/www/html/index.html
  EOF
}