variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-northeast-1"
}

variable "name" {
  description = "Prefix used for naming all resources"
  type        = string
  default     = "task-canvas-stg"
}

variable "frontend_bucket_name" {
  description = "S3 bucket name for the frontend assets (must be globally unique on real AWS)"
  type        = string
  default     = "task-canvas-frontend-stg"
}

variable "container_image" {
  description = "Container image for the API task. Set to the task-canvas backend image pushed to ECR."
  type        = string
}

variable "container_port" {
  type    = number
  default = 8080
}
