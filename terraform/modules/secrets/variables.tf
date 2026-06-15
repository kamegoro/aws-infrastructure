variable "name" {
  description = "Prefix used for naming resources created by this module"
  type        = string
}

variable "db_password" {
  description = "Database master password to store in Secrets Manager"
  type        = string
  sensitive   = true
}

variable "recovery_window_in_days" {
  description = "Number of days Secrets Manager waits before permanently deleting a secret (0 disables the recovery window and deletes immediately)"
  type        = number
  default     = 30
}
