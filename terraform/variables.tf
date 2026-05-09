variable "region" {
  description = "AWS region for the Terraform demo resources."
  type        = string
  default     = "eu-north-1"
}

variable "bucket_suffix" {
  description = "Unique suffix for the S3 demo bucket. Customize this in terraform.tfvars locally."
  type        = string
  default     = "739135301600-lab010"
}

variable "environment" {
  description = "Environment tag for the Terraform demo resources."
  type        = string
  default     = "prod"
}
