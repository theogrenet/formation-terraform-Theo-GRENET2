# envs/staging/outputs.tf

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "ID du VPC staging"
}

output "vpc_cidr" {
  value       = module.vpc.vpc_cidr
  description = "CIDR du VPC staging"
}

output "public_subnet_ids" {
  value       = module.vpc.public_subnet_ids
  description = "Subnets publics staging"
}

output "private_subnet_ids" {
  value       = module.vpc.private_subnet_ids
  description = "Subnets prives staging"
}

output "nat_gateway_public_ip" {
  value       = module.vpc.nat_gateway_public_ip
  description = "IP NAT Gateway staging"
}

output "bastion_security_group_id" {
  value       = module.vpc.bastion_security_group_id
  description = "SG bastion staging"
}
