output "vpc_id" {
  value       = module.networking.vpc_id
  description = "ID of the VPC"
}

output "public_subnet_ids" {
  value       = module.networking.public_subnet_ids
  description = "Public subnet IDs"
}

output "private_subnet_ids" {
  value       = module.networking.private_subnet_ids
  description = "Private subnet IDs"
}

output "data_subnet_ids" {
  value       = module.networking.data_subnet_ids
  description = "Data subnet IDs"
} 