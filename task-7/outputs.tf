output "remote_state_outputs" {
  description = "Outputs from the remote state"
  value = {
    vpc_id            = data.terraform_remote_state.base_infra.outputs.vpc_id
    public_subnet_id  = data.terraform_remote_state.base_infra.outputs.public_subnet_id
    private_subnet_id = data.terraform_remote_state.base_infra.outputs.private_subnet_id
    security_group_id = data.terraform_remote_state.base_infra.outputs.security_group_id
  }
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

output "ssh_connection_command" {
  description = "SSH command to connect to the instance"
  value       = "ssh -i ~/.ssh/your-key.pem ec2-user@${aws_instance.main.public_ip}"
}
