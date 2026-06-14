module "network" {
  source = "../../modules/network"

  name           = var.name
  container_port = var.container_port
}

module "frontend" {
  source = "../../modules/frontend"

  name        = var.name
  bucket_name = var.frontend_bucket_name
}

module "api" {
  source = "../../modules/api"

  name = var.name

  vpc_id                        = module.network.vpc_id
  public_subnet_ids             = module.network.public_subnet_ids
  private_subnet_ids            = module.network.private_subnet_ids
  alb_security_group_id         = module.network.alb_security_group_id
  ecs_service_security_group_id = module.network.ecs_service_security_group_id

  container_image = var.container_image
  container_port  = var.container_port
}
