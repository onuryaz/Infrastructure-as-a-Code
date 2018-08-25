variable "access_key" {
  description = "AWS access key"
  type        = "string"
}

variable "app_port" {
  default     = "80"
  description = "The port the application will use for serving its contents"
  type        = "string"
}

variable "asg_max_size" {
  default     = "3"
  description = "AWS auto scaling group maximum size"
  type        = "string"
}

variable "asg_min_size" {
  default     = "1"
  description = "AWS auto scaling group minimum size"
  type        = "string"
}

variable "db_port" {
  description = "The port for communicating with the database server"
  type        = "string"
}

variable "environment" {
  description = "Environment name"
  type        = "string"
}

variable "http_port" {
  default     = "80"
  description = "The port the server will use for HTTP requests"
  type        = "string"
}

variable "https_port" {
  default     = "443"
  description = "The secured port the server will use for HTTPS requests"
  type        = "string"
}

variable "instance_type" {
  description = "AWS instance type"
  type        = "string"
}

variable "key_pair_name" {
  description = "Key Pair for Deployed Instances"
  type        = "string"
}

variable "ml_ami" {
  description = "AWS image id"
  type        = "string"
}

variable "project" {
  description = "Project name"
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

variable "ssh_port" {
  default     = "22"
  description = "The secure port to getting into the server"
  type        = "string"
}

variable "web_ami" {
  description = "AWS image id"
  type        = "string"
}
