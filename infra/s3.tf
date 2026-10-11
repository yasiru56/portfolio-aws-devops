# The bucket that stores the website files
resource "aws_s3_bucket" "site" {
  bucket = "yasiru-portfolio-${data.aws_caller_identity.current.account_id}"
}

# Block ALL public access – the bucket stays private
resource "aws_s3_bucket_public_access_block" "site" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

output "bucket_name" {
  value = aws_s3_bucket.site.bucket
}