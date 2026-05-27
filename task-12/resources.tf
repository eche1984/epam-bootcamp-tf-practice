resource "aws_iam_policy" "cmtr-d3wf0oa8-iam-policy" {
  name        = "cmtr-d3wf0oa8-iam-policy"
  description = "Custom role with limited permissions"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ec2:*",
          "s3:*"
        ],
        "Resource" : "*"
      }
    ]
  })
}