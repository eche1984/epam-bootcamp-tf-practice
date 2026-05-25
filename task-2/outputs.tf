# Output the public IP for SSH connection
output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.cmtr-d3wf0oa8-ec2.public_ip
}

output "ssh_connection_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ~/.ssh/cmtr-d3wf0oa8-key ec2-user@${aws_instance.cmtr-d3wf0oa8-ec2.public_ip}"
}