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

resource "aws_iam_role" "s3_full_access" {
  name = "s3_full_access"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "s3-full-access-policy-attachment" {
    role = aws_iam_role.s3_full_access.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}


resource "aws_lambda_function" "download_raw_data" {
  filename      = "./../download.zip"
  function_name = "download_raw_data"
  role          = aws_iam_role.s3_full_access.arn
  handler = "download.lambda_handler"
  publish = true
  reserved_concurrent_executions = -1

  source_code_hash = base64sha256("downoad.zip")

  runtime = "python3.9"

  timeout = 900

}


