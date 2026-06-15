resource "aws_security_group" "db" {
  name        = "${var.name}-db"
  description = "Allow inbound PostgreSQL from the ECS service"
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL from the ECS service"
    from_port       = var.port
    to_port         = var.port
    protocol        = "tcp"
    security_groups = [var.allowed_security_group_id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-db"
  }
}
