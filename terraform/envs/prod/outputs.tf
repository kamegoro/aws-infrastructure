output "vpc_id" {
  value = module.network.vpc_id
}

output "frontend_bucket_name" {
  value = module.frontend.bucket_name
}

output "frontend_distribution_domain_name" {
  value = module.frontend.distribution_domain_name
}

output "alb_dns_name" {
  value = module.api.alb_dns_name
}

output "ecs_cluster_name" {
  value = module.api.cluster_name
}

output "ecs_service_name" {
  value = module.api.service_name
}
