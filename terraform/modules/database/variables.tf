variable "name" {
  description = "Prefix used for naming resources created by this module"
  type        = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  description = "Subnet IDs (in at least two AZs) used for the DB subnet group"
  type        = list(string)
}

variable "allowed_security_group_id" {
  description = "Security group ID allowed to connect to the database (typically the ECS service security group)"
  type        = string
}

variable "engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "15"
}

variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GiB"
  type        = number
  default     = 20
}

variable "db_name" {
  type    = string
  default = "taskcanvas"
}

variable "username" {
  type    = string
  default = "taskcanvas"
}

variable "port" {
  type    = number
  default = 5432
}
