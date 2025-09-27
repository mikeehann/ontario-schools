terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

# default
provider "aws" {
  region = var.region
}

# sepcifically for us-east-1 resources.
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}