variable "region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "ca-central-1"
}

variable "domain_name" {
  description = "Root domain name (e.g., map.EXAMPLE.COM"
  type        = string
}

variable "subdomain_name" {
  description = "Subdomain name (e.g., MAP.example.com)"
  type        = string
}

variable "geojson_file" {
  description = "GeoJSON file containing Ontario school data"
  type        = string
}
