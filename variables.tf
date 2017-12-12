variable "access_key" {} # Pulled in from file using 'terraform apply -var-file e:\Scripts\Projects\terraform\terraform.tfvars'
variable "secret_key" {} # Pulled in from file using 'terraform apply -var-file e:\Scripts\Projects\terraform\terraform.tfvars'
variable "public_key" {} # Pulled in from file using 'terraform apply -var-file e:\Scripts\Projects\terraform\terraform.tfvars'
variable "region" {
  default = "eu-west-1"
}