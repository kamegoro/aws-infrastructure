resource "aws_ecr_repository" "api" {
  name                 = "${var.name}-api"
  image_tag_mutability = "MUTABLE"
}
