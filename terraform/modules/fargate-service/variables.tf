variable "name" {
  description = "Prefix used for naming resources created by this module"
  type        = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "alb_security_group_id" {
  type = string
}

variable "ecs_service_security_group_id" {
  type = string
}

variable "container_image" {
  description = <<-EOT
    Container image for the API. Defaults to a small public placeholder image
    so the stack can be applied end-to-end without first building/pushing the
    real task-canvas backend image.
  EOT
  type        = string
  default     = "public.ecr.aws/docker/library/httpd:2.4"
}

variable "container_port" {
  type    = number
  default = 8080
}

variable "container_cpu" {
  type    = number
  default = 256
}

variable "container_memory" {
  type    = number
  default = 512
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "environment" {
  description = "Extra environment variables passed to the container"
  type        = map(string)
  default     = {}
}

variable "secrets" {
  description = "Map of container environment variable name to Secrets Manager secret ARN"
  type        = map(string)
  default     = {}
}

variable "health_check_path" {
  type    = string
  default = "/"
}
