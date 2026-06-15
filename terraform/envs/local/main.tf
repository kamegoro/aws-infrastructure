module "network" {
  source = "../../modules/network"

  name           = var.name
  container_port = var.container_port
}

module "static_site" {
  source = "../../modules/static-site"

  name        = var.name
  bucket_name = var.frontend_bucket_name
}

module "ecr" {
  source = "../../modules/ecr"

  name = var.name
}

module "database" {
  source = "../../modules/database"

  name = var.name

  vpc_id                    = module.network.vpc_id
  private_subnet_ids        = module.network.private_subnet_ids
  allowed_security_group_id = module.network.ecs_service_security_group_id
}

module "secrets" {
  source = "../../modules/secrets"

  name = var.name

  db_password = module.database.password
}

module "fargate_service" {
  source = "../../modules/fargate-service"

  name = var.name

  vpc_id                        = module.network.vpc_id
  public_subnet_ids             = module.network.public_subnet_ids
  private_subnet_ids            = module.network.private_subnet_ids
  alb_security_group_id         = module.network.alb_security_group_id
  ecs_service_security_group_id = module.network.ecs_service_security_group_id

  container_image = var.container_image
  container_port  = var.container_port

  environment = {
    POSTGRES_HOST = module.database.endpoint
    POSTGRES_PORT = tostring(module.database.port)
    POSTGRES_DB   = module.database.db_name
    POSTGRES_USER = module.database.username
  }

  secrets = {
    JWT_SECRET        = module.secrets.jwt_secret_arn
    POSTGRES_PASSWORD = module.secrets.db_password_secret_arn
  }

  # MiniStackがECSタスク定義のsecretsをコンテナに注入しない制約の回避策(#106)
  secrets_as_environment = true
}
