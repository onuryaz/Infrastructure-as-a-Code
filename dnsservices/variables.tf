variable "access_key" {
  description = "AWS access key"
  type        = "string"
}

variable "region" {
  default     = "us-east-1"
  description = "AWS region"
  type        = "string"
}

variable "secret_key" {
  description = "AWS secret key"
  type        = "string"
}