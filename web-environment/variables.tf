#variable "access_key" {} # Pulled in from file using 'terraform apply -var-file e:\Scripts\Projects\terraform\terraform.tfvars'
#variable "secret_key" {} # Pulled in from file using 'terraform apply -var-file e:\Scripts\Projects\terraform\terraform.tfvars'
variable "region" {
  default = "eu-west-1"
}
variable "private-subnets" {
  description = "Run the EC2 Instances in these Public Subnets"
  type = "list"
  default = ["subnet-faea35a1", "subnet-d94cdfbe", "subnet-861289cf"]
}

variable "web-ports" {
  description = "The port which will be used to connect to the web servers"
  type = "string"
  default = 8080
}