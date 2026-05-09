resource "aws_s3_bucket" "demo" {
  bucket = "cicd-lab-demo-${var.bucket_suffix}"

  tags = {
    Name        = "cicd-lab-demo-${var.bucket_suffix}"
    Environment = var.environment
    Project     = "cicd-lab"
    ManagedBy   = "Terraform"
  }
}

resource "aws_s3_bucket_public_access_block" "demo" {
  bucket = aws_s3_bucket.demo.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "demo" {
  bucket = aws_s3_bucket.demo.id

  versioning_configuration {
    status = "Enabled"
  }
}

output "demo_bucket_name" {
  description = "Name of the S3 bucket created by the Terraform demo."
  value       = aws_s3_bucket.demo.bucket
}
