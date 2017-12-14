#variable "access_key" {} # Pulled in from file using 'terraform apply -var-file e:\Scripts\Projects\terraform\terraform.tfvars'
#variable "secret_key" {} # Pulled in from file using 'terraform apply -var-file e:\Scripts\Projects\terraform\terraform.tfvars'
variable "region" {
  default = "eu-west-1"
}
variable "public-subnets" {
  description = "Run the EC2 Instances in these Public Subnets"
  type = "list"
  default = ["subnet-faf02fa1", "subnet-46178c0f", "subnet-304fdc57"]
}