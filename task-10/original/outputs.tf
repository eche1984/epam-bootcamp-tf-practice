output "discovered_vpc_id" {
  description = "ID of the discovered VPC"
  value       = data.aws_vpc.main.id
}

output "discovered_vpc_cidr" {
  description = "CIDR block of the discovered VPC"
  value       = data.aws_vpc.main.cidr_block
}

output "discovered_subnet_id" {
  description = "ID of the discovered public subnet"
  value       = data.aws_subnet.public.id
}

output "discovered_subnet_cidr" {
  description = "CIDR block of the discovered public subnet"
  value       = data.aws_subnet.public.cidr_block
}

output "discovered_security_group_id" {
  description = "ID of the discovered security group"
  value       = data.aws_security_group.main.id
}

output "ec2_instance_id" {
  description = "ID of the created EC2 instance"
  value       = aws_instance.main.id
}

output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.main.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.main.public_dns
}

output "used_ami_id" {
  description = "AMI ID used for the EC2 instance"
  value       = data.aws_ami.amazon_linux_2023.id
}

output "ssh_connection_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ~/.ssh/your-key.pem ec2-user@${aws_instance.main.public_ip}"
}