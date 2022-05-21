terraform {
  required_version = ">= 1.0"
  backend "local" {}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}

# AWS S3 Bucket 
resource "aws_s3_bucket" "b" {
  bucket = var.bucket_name

  tags = {
    Name        = "r/place"
    Environment = "Dev"
  }
}

# AWS S3 Bucket ACL
resource "aws_s3_bucket_acl" "acl" {
  bucket = aws_s3_bucket.b.id
  acl    = "private"
}

# AWS S3 Bucket life-cycle
resource "aws_s3_bucket_lifecycle_configuration" "bucket-config" {
  bucket = aws_s3_bucket.b.id

  rule {
    id = "rule-1"

    expiration {
      days = 110
    }

    status = "Enabled"

    transition {
      days          = 45
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 75
      storage_class = "GLACIER"
    }
  }
}

