variable "project" {
  description = "Project name used for naming resources"
  type        = string
}

variable "environment" {
  description = "Environment Name"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "db_username" {
  description = "Master username for RDS PostgreSQL"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Master password for RDS PostgreSQL (min 8 chars)"
  type        = string
  sensitive   = true
}

variable "public_key" {
  description = "Public SSH key content to connect to EC2"
  type        = string
  sensitive   = true
}
