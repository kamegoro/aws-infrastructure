output "vpc_id" {
  value = module.network.vpc_id
}

output "frontend_bucket_name" {
  value = module.static_site.bucket_name
}

output "frontend_distribution_domain_name" {
  value = module.static_site.distribution_domain_name
}

output "alb_dns_name" {
  value = module.fargate_service.alb_dns_name
}

output "ecs_cluster_name" {
  value = module.fargate_service.cluster_name
}

output "ecs_service_name" {
  value = module.fargate_service.service_name
}

output "db_endpoint" {
  value = module.database.endpoint
}

output "db_port" {
  value = module.database.port
}

output "db_name" {
  value = module.database.db_name
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}
