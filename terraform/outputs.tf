output "public_website_bucket_name" {
  description = "The name of the S3 bucket hosting the static website files."
  value       = aws_s3_bucket.website_bucket.id
}

output "private_data_bucket_name" {
  description = "The name of the S3 bucket hosting the private GeoJSON data."
  value       = aws_s3_bucket.private_data_bucket.id
}

output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution."
  value       = aws_cloudfront_distribution.s3_distribution.id
}

output "website_url" {
  description = "The final URL of the live website."
  value       = "https://${one(aws_cloudfront_distribution.s3_distribution.aliases)}"
}

output "api_gateway_invoke_url" {
  description = "The base invoke URL for the HTTP API Gateway."
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}
