variable "region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "domain_name" {
  description = "Root domain name (e.g., example.com)"
  type        = string
}

variable "subdomain_name" {
  description = "Subdomain name (e.g., map.example.com)"
  type        = string
}
