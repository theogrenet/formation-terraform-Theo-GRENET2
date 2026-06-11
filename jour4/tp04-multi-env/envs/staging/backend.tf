# envs/staging/backend.tf
# State séparé de dev : un apply staging ne peut pas casser dev.

terraform {
  backend "s3" {
    bucket       = "tf-state-theo-grenet-formation"
    key          = "envs/staging/vpc/terraform.tfstate"
    region       = "eu-west-3"
    encrypt      = true
    use_lockfile = true
  }
}


