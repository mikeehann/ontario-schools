# generate random string
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket" "website_bucket" {
  bucket = "${var.subdomain_name}-${var.domain_name}-public-static-${random_string.bucket_suffix.result}"

  tags = {
    Name = "Host Bucket"
  }
}

resource "aws_s3_bucket" "private_data_bucket" {
  bucket = "${var.subdomain_name}-${var.domain_name}-private-data-${random_string.bucket_suffix.result}"

  tags = {
    Name = "Data Bucket"
  }
}

resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "index.html" # TODO: update to error.html
  }
}

resource "aws_s3_bucket_public_access_block" "website_bucket_pab" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "website_bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.website_bucket.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.website_bucket_pab]
}

resource "aws_s3_bucket_public_access_block" "private_bucket_pab" {
  bucket = aws_s3_bucket.private_data_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}