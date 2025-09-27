data "aws_route53_zone" "primary" {
  name = var.domain_name
}

# find the existing cert
data "aws_acm_certificate" "cert" {
  provider = aws.us-east-1
  domain   = "${var.domain_name}" # ACM cert is good foor both top-level and sub-domains
  statuses = ["ISSUED"] 
}
