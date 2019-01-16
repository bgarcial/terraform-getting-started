# Let's first extract our access key, secret key, and region into a few variables.
# This defines three variables within your Terraform configuration. 
# The first two have empty blocks {}. 
# The third sets a default. If a default value is set, the variable is optional. 
# Otherwise, the variable is required. If you run terraform plan now, 
# Terraform will prompt you for the values for unset string variables. 
variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "eu-central-1"
}
variable "amis" {
  type = "map"
  default = {
    "eu-central-1" = "ami-d15d663a"
    "eu-west-1" = "ami-662b3e12"
  }
}

