variable "name" {
  description = "Prefix used for naming all resources"
  type        = string
  default     = "task-canvas"
}

variable "frontend_bucket_name" {
  description = "S3 bucket name for the frontend assets (must be globally unique on real AWS)"
  type        = string
  default     = "task-canvas-frontend-local"
}

variable "container_image" {
  description = "Container image for the API task. Override with the real task-canvas backend image once it's pushed to MiniStack's ECR."
  type        = string
  default     = "public.ecr.aws/docker/library/httpd:2.4"
}

variable "container_port" {
  type    = number
  default = 8080
}
