# envs/dev/main.tf
# Appel du module VPC avec les paramètres de l'environnement dev.

module "vpc" {
  source = "../../modules/vpc"

  environment          = "dev"
  project_name         = "theo"
  vpc_cidr             = "10.10.0.0/16" # dev : plage 10.10.x, isolé de staging
  azs                  = ["eu-west-3a", "eu-west-3b"]
  bastion_allowed_cidr = "0.0.0.0/0"
}
