output "ssh_sg_name" {
  description = "Name of the SSH Security Group"
  value       = aws_security_group.ssh_sg.name
}

output "public_http_sg_name" {
  description = "Name of the Public HTTP Security Group"
  value       = aws_security_group.public_http_sg.name
}

output "private_http_sg_name" {
  description = "Name of the Private HTTP Security Group"
  value       = aws_security_group.private_http_sg.name
}
