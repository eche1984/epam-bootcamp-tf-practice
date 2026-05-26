output "aws_iam_group_name" {
  description = "Name of the AWS IAM Group"
  value       = aws_iam_group.main.name
}

output "aws_iam_policy_name" {
  description = "Name of the AWS IAM Policy"
  value       = aws_iam_policy.main.name
}

output "aws_iam_role_name" {
  description = "Name of the AWS IAM Role"
  value       = aws_iam_role.main.name
}

output "aws_iam_instance_profile_name" {
  description = "Name of the AWS IAM Instance Profile"
  value       = aws_iam_instance_profile.main.name
}
