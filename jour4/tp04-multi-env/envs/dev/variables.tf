# envs/dev/variables.tf
# Une seule variable : les valeurs dev sont hardcodées dans main.tf (explicite).

variable "aws_region" {
  type        = string
  description = "Region AWS"
  default     = "eu-west-3"
}
