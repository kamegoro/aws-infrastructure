variable "name" {
  description = "Prefix used for naming resources created by this module"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket that stores the built frontend assets"
  type        = string
}

variable "default_root_object" {
  description = "Object returned for requests to the distribution root (e.g. index.html)"
  type        = string
  default     = "index.html"
}

variable "spa_routing" {
  description = "If true, configure 403/404 responses to fall back to default_root_object (for client-side routed SPAs)"
  type        = bool
  default     = true
}

variable "price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_200"
}
