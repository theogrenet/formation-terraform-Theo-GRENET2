# providers.tf

# Déclare Terraform + provider AWS avec les tags par défaut sur toutes les ressources.

terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Ces tags s'appliquent automatiquement sur TOUTES mes ressources AWS

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "formation-terraform"
      Module      = "tp03-web-ec2"
      ManagedBy   = "Terraform"
      Environment = var.environment
      Owner       = "etudiant08"
    }
  }
}
