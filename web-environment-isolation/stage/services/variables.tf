# Region Var
variable "region" {
  default = "eu-west-1"
}

# Specify the public subnets to use.
variable "public-subnets" {
  description = "Run the EC2 Instances in these Public Subnets"
  type = "list"
  default = ["subnet-faf02fa1", "subnet-46178c0f", "subnet-304fdc57"]
}

# Specify the web ports to contact the server on
variable "web-ports" {
  description = "The port which will be used to connect to the web servers"
  type = "string"
  default = 8080
}