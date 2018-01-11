# Author Jamie McKay

# Script Goals - Build 2 Load Balanced Web servers which can be accessed via tha bastion over SSH. 
# Web servers deployed across AZs in Ireland

# Note to self - This will use ASG and build immutable Web Instances... i.e. no ssh access provided.

# This script is stored in GitHub - git@github.com:d3adv3gas/j2k2-deploy

# Setup the Provider - Variable provied by file
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

# Configure Terraform 
terraform {
  backend "s3" { # Use the noted S3 bucket to store state
    bucket  = "j2k2-tf-bucket"
    key     = "tfstate/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = "true"
  }
}

# Specify Data Surces
data "aws_availability_zones" "all" {} # List all AZs available

# Create an Auto Scaling Group Launch Configuration
resource "aws_launch_configuration" "Web-lc" {
  image_id = "ami-785db401" # Machine Version
  instance_type = "t2.micro" # Instance Type
  key_name = "j2k2lablinux" # Use this key
  security_groups = ["${aws_security_group.web-sg.id}"] # Add to the Web-sg Security Group
  # associate_public_ip_address = "true" # Add a Public IP
  # subnet_ids     = "${var.public-subnets [count.index]}"
  
  user_data = <<-EOF
    #!/bin/bash
    echo "Hello - I am server a server created via an AutoScaling Group" > index.html
    nohup busybox httpd -f -p ${var.web-ports} &
    EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web-asg" {
  launch_configuration = "${aws_launch_configuration.Web-lc.id}"
  availability_zones = ["${data.aws_availability_zones.all.names}"]
  vpc_zone_identifier = ["${var.private-subnets [count.index]}"] # Specify private subnets to deploy servers into

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

resource "aws_security_group" "web-sg" { # Create a security group in Lab VPC
  name = "web-sg"
  vpc_id = "vpc-fb57cc9c"

  ingress { # Specify ingress rules providing cidr blocks and security group ids (if required)
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["151.224.16.41/32","172.16.0.106/32"]
  }

  lifecycle {
    create_before_destroy = "true"
  }
}
