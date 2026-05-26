resource "aws_s3_bucket" "main" {
  bucket = "cmtr-d3wf0oa8-bucket-1779754616"

  tags = {
    Project = var.project_tag
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
