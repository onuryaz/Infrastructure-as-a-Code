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

variable "db_identifier" {
  description = "Database snapshot identifier"
  type        = "string"
}

variable "db_storage_size" {
  description = "Database storage capacity"
  type        = "string"
}

variable "db_storage_type" {
  description = "Database storage type"
  type        = "string"
}

variable "db_port" {
  description = "The port for communicating with the database server"
  type        = "string"
}

variable "db_engine" {
  description = "Database engine"
  type        = "string"
}

variable "db_engine_version" {
  description = "Database engine version"
  type        = "string"
}

variable "db_instance_class" {
  description = "Database instance type"
  type        = "string"
}

variable "db_name" {
  description = "The database name"
  type        = "string"
}

variable "db_username" {
  description = "Database username"
  type        = "string"
}

variable "db_password" {
  description = "Database password"
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

variable "instance_type" {
  description = "AWS instance type"
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
