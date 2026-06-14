variable "name" {
  description = "Prefix used for naming resources created by this module"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability zones to spread subnets across"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (one per AZ)"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "container_port" {
  description = "Port the ECS service listens on, used to scope the ECS security group ingress rule"
  type        = number
  default     = 8080
}

variable "enable_nat_gateway" {
  description = <<-EOT
    Whether to create a NAT Gateway for private subnet egress.
    NAT Gateways incur an hourly + data processing cost on real AWS,
    so keep this false unless you specifically need outbound internet
    access from ECS tasks (e.g. to pull images from public registries
    or call external APIs).
  EOT
  type        = bool
  default     = false
}
