data "aws_route53_zone" "primary" {
  name = var.domain_name
}

# find the existing cert
data "aws_acm_certificate" "cert" {
  provider = aws.us-east-1
  domain   = "*.${var.domain_name}"
  statuses = ["ISSUED"] 
}
