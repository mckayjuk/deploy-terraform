# NOTE - - Currently I can't 'Destory' once built due to the requirment for a final snapshot. Look this up.

provider "aws" {
    region = "eu-west-1"
}

# Configure Terraform
terraform {
  backend "s3" { # Use the noted S3 bucket to store state
    bucket  = "j2k2-tf-bucket"
    key     = "tfstate/web-environment-isolation/stage/mysql/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = "true"
  }
}

#create the subnet group with subnets from var file for the DB Instances
resource "aws_db_subnet_group" "mysql-subnet-group" {
  name       = "main"
  subnet_ids = ["${var.private-subnets}"]

  tags {
    Name = "My DB subnet group"
  }
}

#Create a mysql instance
resource "aws_db_instance" "web-db" {
    engine = "mysql"
    allocated_storage = 10
    instance_class = "db.t2.micro"
    name = "webmysql"
    username = "admin"
    password = "${var.db_password}"
    db_subnet_group_name = "${aws_db_subnet_group.mysql-subnet-group.id}"
}