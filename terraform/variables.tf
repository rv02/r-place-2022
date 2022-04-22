variable "bucket_name" {
  description = "Name of your s3 bucket"
}

variable "region" {
  description = "Region for AWS resources"
  default     = "ap-south-1"
  type        = string
}