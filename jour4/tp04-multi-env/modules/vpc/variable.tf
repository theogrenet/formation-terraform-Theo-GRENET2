# modules/vpc/variables.tf
# Interface publique du module VPC.
# Pas de default sur environment/project_name/vpc_cidr : l'appelant DOIT les fournir.

# Pas d'aws_region ici : c'est l'appelant qui configure le provider

variable "environment" {
  type        = string
  description = "Environnement (dev, staging, prod)"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment doit etre dev, staging ou prod."
  }
}

variable "project_name" {
  type        = string
  description = "Prefixe pour nommer les ressources"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR du VPC (ex: 10.10.0.0/16)"

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr doit etre un CIDR valide."
  }
}

# default conservé : valeur raisonnable pour la formation
variable "azs" {
  type        = list(string)
  description = "Liste des AZ (minimum 2 pour la HA)"
  default     = ["eu-west-3a", "eu-west-3b"]

  validation {
    condition     = length(var.azs) >= 2
    error_message = "Au moins 2 AZ requises."
  }
}

# default conservé : à restreindre en prod
variable "bastion_allowed_cidr" {
  type        = string
  description = "CIDR autorise en SSH sur le bastion (jamais 0.0.0.0/0 en prod)"
  default     = "0.0.0.0/0"
}
