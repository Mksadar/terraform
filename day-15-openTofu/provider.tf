provider "aws" {
  
}

terraform {
  required_providers {
    aws = {
      source  = "opentofu/aws"
      version = ">= 4.0.0"
    }
  }
}
