resource "aws_ecs_cluster" "main" {
  name = "${var.name}-cluster"
}

resource "aws_cloudwatch_log_group" "api" {
  name              = "/ecs/${var.name}-api"
  retention_in_days = 14
}

# MiniStackのRunTask実装がsecrets(valueFrom)をコンテナに注入しない制約の
# 回避策(var.secrets_as_environment)。secrets_as_environment=trueの場合のみ、
# var.secretsで指定されたARNの値をTerraformが解決する。
data "aws_secretsmanager_secret_version" "for_environment" {
  for_each  = var.secrets_as_environment ? var.secrets : {}
  secret_id = each.value
}

resource "aws_ecs_task_definition" "api" {
  family                   = "${var.name}-api"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name      = "api"
      image     = var.container_image
      essential = true

      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]

      environment = concat(
        [for key, value in var.environment : { name = key, value = value }],
        var.secrets_as_environment ? [
          for key, arn in var.secrets : {
            name  = key
            value = data.aws_secretsmanager_secret_version.for_environment[key].secret_string
          }
        ] : []
      )

      secrets = var.secrets_as_environment ? [] : [
        for key, arn in var.secrets : { name = key, valueFrom = arn }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.api.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "api"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "api" {
  name            = "${var.name}-api"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.api.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_service_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.api.arn
    container_name   = "api"
    container_port   = var.container_port
  }

  depends_on = [aws_lb_listener.http]
}
