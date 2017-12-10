# Author Jamie McKay
# Version 0.1
# Date 10/12/2017

# Script Goals - Build a 2 Tier Environment (web/app, Data). Load Balanced Web front end (basic HTML which reads data in a DB (simple String)) using ELB. 
# Web servers deployed across AZs in Ireland. mySQL DB using RDS.
# This script will build the infra and Ansible will create the HTML

# This script is stored in GitHub - https://github.com/d3adv3gas/aws-test

# Setup the Provider - Variable provied by file
provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

# Create the Web Server(s)
resource "aws_instance" "j2k2-test-build" {
  ami           = "ami-bb9a6bc2"
  instance_type = "t2.micro"
  subnet_id     = "subnet-faea35a1"
  key_name      = "j2k2lablinux"
  security_groups = ["sg-a7ec92df"]
  associate_public_ip_address = "true"
}


