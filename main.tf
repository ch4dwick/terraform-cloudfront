terraform {
  # backend "s3" {
  #   bucket = "my-bucket"
  #   # Optional
  #   key    = "my-cdn-files"
  #   region = "ap-southeast-1"

  # }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.30.0"
    }
  }

  required_version = ">= 1.2.7"
}

provider "aws" {
  profile = "default"
  region  = "ap-southeast-1"
}
