# IAM Group
resource "aws_iam_group" "main" {
  name = "${var.project_tag}-iam-group"
}

# IAM Policy (using templatefile)
resource "aws_iam_policy" "main" {
  name        = "${var.project_tag}-iam-policy"
  description = "Custom IAM policy granting write permissions to S3 bucket"

  policy = templatefile("${path.module}/files/policy.json.tpl", {
    bucket_name = "${var.project_tag}-bucket-1779804994"
  })

  tags = {
    Project = "${var.project_tag}"
  }
}

# Attach policy to group (optional but good practice)
resource "aws_iam_group_policy_attachment" "main" {
  group      = aws_iam_group.main.name
  policy_arn = aws_iam_policy.main.arn
}

# IAM Role with trust relationship for EC2
resource "aws_iam_role" "main" {
  name = "${var.project_tag}-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project = "${var.project_tag}"
  }
}

# Attach the custom policy to the role
resource "aws_iam_role_policy_attachment" "main" {
  role       = aws_iam_role.main.name
  policy_arn = aws_iam_policy.main.arn
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "main" {
  name = "${var.project_tag}-iam-instance-profile"
  role = aws_iam_role.main.name

  tags = {
    Project = "${var.project_tag}"
  }
}