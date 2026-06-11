# envs/staging/main.tf
# Même module VPC que dev, différentes valeurs.

module "vpc" {
  source = "../../modules/vpc"

  environment          = "staging"
  project_name         = "theo"
  vpc_cidr             = "10.20.0.0/16" # staging : plage 10.20.x, isolé de dev
  azs                  = ["eu-west-3a", "eu-west-3b"]
  bastion_allowed_cidr = "0.0.0.0/0"
}
