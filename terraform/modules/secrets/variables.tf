variable "name" {
  description = "Prefix used for naming resources created by this module"
  type        = string
}

variable "db_password" {
  description = "Database master password to store in Secrets Manager"
  type        = string
  sensitive   = true
}
