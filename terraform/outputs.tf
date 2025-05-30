output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "monitoring_private_ip" {
  value = module.monitoring.private_ip
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "monitoring_security_group_id" {
  description = "Security group ID of the monitoring instance"
  value       = module.monitoring.security_group_id
}