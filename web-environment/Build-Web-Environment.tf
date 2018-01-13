############################################################################################
# Author Jamie McKay

# Script Goals - Build and Auto scaled, Load Balanced set of web servers. 
# Web servers deployed across AZs in Ireland
# This script is stored in GitHub - git@github.com:d3adv3gas/j2k2-deploy

# Note, since Terraform is declarative, the order of resource creation is not important (other than for easier comprehension by the reader)

########## Setup the Provider - Variable provied by file ###################
provider "aws" {
  profile   = "default"
  
  /*
  # AWS Access Keys to be added to the local terraform.tfvars file if required
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  */

  # AWS Access using the local AWS Credentials 
  shared_credentials_file = "~/.aws/credentials" # Linux IDE
  region     = "${var.region}"
}

########## Configure Terraform ########################################
terraform {
  backend "s3" { # Use the noted S3 bucket to store state
    bucket  = "j2k2-tf-bucket"
    key     = "tfstate/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = "true"
  }
}

########## Specify Data Surces ########################################
data "aws_availability_zones" "all" {} # List all AZs available

########## Create an Auto Scaling Group Launch Configuration ##########
resource "aws_launch_configuration" "Web-lc" {
  name_prefix = "web-lc-" # don't pin the name as it affects ability to disconnect and recreate.
  image_id = "ami-785db401" # Machine Version
  instance_type = "t2.micro" # Instance Type
  key_name = "j2k2lablinux" # Use this key
  security_groups = ["${aws_security_group.web-sg.id}"] # Add to the Web-sg Security Group
  
  user_data = <<-EOF # Configure user data... i.e. config to apply locally (without the use of remote-exec)
    #!/bin/bash
    echo "Hello - I am server a server created via an AutoScaling Group" > index.html #creates a simple web page
    nohup busybox httpd -f -p ${var.web-ports} &
    EOF

  lifecycle {
    create_before_destroy = true
  }
}

########## Create a VPC ################################################
resource "aws_vpc" "testapp-dev-vpc" {
  cidr_block = "172.16.4.0/22"

  tags {
    name = "testapp-dev-vpc"
  }
}

########## Create a Private subnet in eu-west 1a #######################
resource "aws_subnet" "testapp-dev-euw1a-private" {
  vpc_id     = "${aws_vpc.testapp-dev-vpc.id}"
  availability_zone = "${data.aws_availability_zones.all.names[0]}"
  cidr_block = "172.16.4.0/24"

  tags {
    name = "testapp-dev-euw1a-private"
  }
}

########## Create a Private subnet in eu-west 1b #######################
resource "aws_subnet" "testapp-dev-euw1b-private" {
  vpc_id     = "${aws_vpc.testapp-dev-vpc.id}"
  availability_zone = "${data.aws_availability_zones.all.names[1]}"
  cidr_block = "172.16.5.0/24"

   tags {
    name = "testapp-dev-euw1b-private"
  }
}

########## Create a Private subnet in eu-west 1c #######################

resource "aws_subnet" "testapp-dev-euw1c-private" {
  vpc_id     = "${aws_vpc.testapp-dev-vpc.id}"
  availability_zone = "${data.aws_availability_zones.all.names[2]}"
  cidr_block = "172.16.6.0/24"

   tags {
    name = "testapp-dev-euw1c-private"
  }
}

########## Create the web autoscaling group#############################
# 
resource "aws_autoscaling_group" "web-asg" {
  name_prefix = "web-asg-"
  launch_configuration = "${aws_launch_configuration.Web-lc.id}"
  availability_zones = ["${data.aws_availability_zones.all.id}"]
  vpc_zone_identifier = ["${aws_subnet.testapp-dev-euw1a-private.id}", "${aws_subnet.testapp-dev-euw1b-private.id}","${aws_subnet.testapp-dev-euw1c-private.id}"] # Specify private subnets to deploy servers into

  min_size = 2
  max_size = 3

  tag {
    key = "Name"
    value = "web-asg"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = "true"
  }
}

########### Create the web server load balancer #############################

########### Create the web Security Group #############################
resource "aws_security_group" "web-sg" { # Create a security group in Lab VPC
  name_prefix = "web-sg-"
  vpc_id = "${aws_vpc.testapp-dev-vpc.id}"

  ingress { # Specify ingress rules providing cidr blocks and security group ids (if required)
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["172.16.0.106/32"] # Which IPs does this relate to? You can also use other security groups
  }

  lifecycle {
    create_before_destroy = "true"
  }
}
