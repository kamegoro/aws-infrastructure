output "repository_url" {
  description = "URL of the ECR repository for the API image"
  value       = aws_ecr_repository.api.repository_url
}
