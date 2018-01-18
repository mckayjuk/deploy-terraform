# Create a password for the DB access (this is just a test and would not normally be done like this)
variable "db_password" {
    description = "The password var for the DB"
}

# Subnets used for DB Instance
variable "private-subnets" {
  description = "Run the EC2 Instances in these Public Subnets"
  type = "list"
  default = ["subnet-d94cdfbe", "subnet-faea35a1", "subnet-861289cf"]
}