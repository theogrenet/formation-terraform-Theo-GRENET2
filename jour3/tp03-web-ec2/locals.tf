# locals.tf

# Valeurs calculées à partir des variables. Pas surchargeable de l'extérieur.

# ----- LOCALS TP02 -----

locals {
  # Préfixe commun : "theo-dev"
  name_prefix = "${var.project_name}-${var.environment}"

  # Map AZ -> CIDR public : { "eu-west-3a" = "10.0.1.0/24", "eu-west-3b" = "10.0.2.0/24" }
  public_subnets = {
    for idx, az in var.azs : az => cidrsubnet(var.vpc_cidr, 8, idx + 1)
  }

  # Map AZ -> CIDR privé : { "eu-west-3a" = "10.0.101.0/24", "eu-west-3b" = "10.0.102.0/24" }
  private_subnets = {
    for idx, az in var.azs : az => cidrsubnet(var.vpc_cidr, 8, idx + 101)
  }

  # ----- LOCALS TP03 -----

  # Map AZ -> ID subnet privé, utilisée par for_each sur aws_instance.web
  # Construite à partir des subnets privés déjà créés dans vpc.tf
  web_subnets = {
    for k, s in aws_subnet.private : k => s.id
  }

}

