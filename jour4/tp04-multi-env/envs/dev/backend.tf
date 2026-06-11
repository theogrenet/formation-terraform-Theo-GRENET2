# envs/dev/backend.tf
# State stocké dans S3 : s3://tf-state-theo-grenet-formation/envs/dev/vpc/terraform.tfstate
# use_lockfile = true : locking natif S3 (TF >= 1.10), pas besoin de DynamoDB

terraform {
  backend "s3" {
    bucket       = "tf-state-theo-grenet-formation"
    key          = "envs/dev/vpc/terraform.tfstate"
    region       = "eu-west-3"
    encrypt      = true
    use_lockfile = true
  }
}
