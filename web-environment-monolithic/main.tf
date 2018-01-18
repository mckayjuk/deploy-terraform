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
    key     = "tfstate/web-environment-monolithic/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = "true"
  }
}

########## Specify Data Surces ########################################
data "aws_availability_zones" "available" {} # List all AZs available

########## Create an Auto Scaling Group Launch Configuration ##########
resource "aws_launch_configuration" "Web-lc" {
  name_prefix = "web-lc-" # Do not pin the  Name as it affects ability to disconnect and recreate
  image_id = "ami-785db401" # Machine Version
  instance_type = "t2.micro" # Instance Type
  key_name = "j2k2lablinux" # Use this key
  security_groups = ["${aws_security_group.web-sg.id}"] 
  
  user_data = <<-EOF
    #!/bin/bash
    echo "Hello - I am a test web server behind a load balancer" > index.html
    nohup busybox httpd -f -p ${var.web-ports} &
    EOF

  lifecycle {
    create_before_destroy = true
  }
}

########## Create a VPC ################################################
resource "aws_vpc" "testapp-dev-vpc" {
  cidr_block = "172.16.8.0/21"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name = "testapp-dev-vpc"
  }
}

########## Create an internet gateway and attach to vpc ################
resource "aws_internet_gateway" "testapp-dev-vpc-igw" {
  vpc_id = "${aws_vpc.testapp-dev-vpc.id}"

  tags {
    Name = "testapp-dev-vpc-igw"
  }
}

########## Create a Public subnet in eu-west 1a #######################
resource "aws_subnet" "testapp-dev-euw1a-public" {
  vpc_id     = "${aws_vpc.testapp-dev-vpc.id}"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  cidr_block = "172.16.8.0/24"
  map_public_ip_on_launch = "true"
  depends_on = ["aws_internet_gateway.testapp-dev-vpc-igw"]
  
  tags {
    Name = "testapp-dev-euw1a-public"
  }
}

########## Create a Route Table for Public subnet in eu-west 1a #######################
resource "aws_route_table" "web-rt-pub1a" {
  vpc_id = "${aws_vpc.testapp-dev-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.testapp-dev-vpc-igw.id}"
  }

tags {
    Name = "web-rt-pub1a"
  }
}

########## Create a Route Table Association for Public subnet in eu-west 1a #######################
resource "aws_route_table_association" "web-rta-pub1a" {
  subnet_id      = "${aws_subnet.testapp-dev-euw1a-public.id}"
  route_table_id = "${aws_route_table.web-rt-pub1a.id}"
}

########## Create a Public subnet in eu-west 1b #######################
resource "aws_subnet" "testapp-dev-euw1b-public" {
  vpc_id     = "${aws_vpc.testapp-dev-vpc.id}"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  cidr_block = "172.16.9.0/24"
  map_public_ip_on_launch = "true"
  depends_on = ["aws_internet_gateway.testapp-dev-vpc-igw"]
  
  tags {
    Name = "testapp-dev-euw1b-public"
  }
}

########## Create a Route Table for Public subnet in eu-west 1b #######################
resource "aws_route_table" "web-rt-pub1b" {
  vpc_id = "${aws_vpc.testapp-dev-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.testapp-dev-vpc-igw.id}"
  }

  tags {
    Name = "web-rt-pub1b"
  }
}

########## Create a Route Table Association for Public subnet in eu-west 1b #######################
resource "aws_route_table_association" "web-rta-pub1b" {
  subnet_id      = "${aws_subnet.testapp-dev-euw1b-public.id}"
  route_table_id = "${aws_route_table.web-rt-pub1b.id}"
}

########## Create a Public subnet in eu-west 1c #######################
resource "aws_subnet" "testapp-dev-euw1c-public" {
  vpc_id     = "${aws_vpc.testapp-dev-vpc.id}"
  availability_zone = "${data.aws_availability_zones.available.names[2]}"
  cidr_block = "172.16.10.0/24"
  map_public_ip_on_launch = "true"
  depends_on = ["aws_internet_gateway.testapp-dev-vpc-igw"]

  tags {
    Name = "testapp-dev-euw1c-public"
  }
}

########## Create a Route Table for Public subnet in eu-west 1c #######################
resource "aws_route_table" "web-rt-pub1c" {
  vpc_id = "${aws_vpc.testapp-dev-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.testapp-dev-vpc-igw.id}"
  }

  tags {
    Name = "web-rt-pub1c"
  }
}

########## Create a Route Table Association for Public subnet in eu-west 1c #######################
resource "aws_route_table_association" "web-rta-pub1c" {
  subnet_id      = "${aws_subnet.testapp-dev-euw1c-public.id}"
  route_table_id = "${aws_route_table.web-rt-pub1c.id}"
}

########## Create a Private subnet in eu-west 1a #######################
resource "aws_subnet" "testapp-dev-euw1a-private" {
  vpc_id     = "${aws_vpc.testapp-dev-vpc.id}"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  cidr_block = "172.16.11.0/24"

  tags {
    Name = "testapp-dev-euw1a-private"
  }
}

########## Create a Private subnet in eu-west 1b #######################
resource "aws_subnet" "testapp-dev-euw1b-private" {
  vpc_id     = "${aws_vpc.testapp-dev-vpc.id}"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  cidr_block = "172.16.12.0/24"

   tags {
    Name = "testapp-dev-euw1b-private"
  }
}

########## Create a Private subnet in eu-west 1c #######################
resource "aws_subnet" "testapp-dev-euw1c-private" {
  vpc_id     = "${aws_vpc.testapp-dev-vpc.id}"
  availability_zone = "${data.aws_availability_zones.available.names[2]}"
  cidr_block = "172.16.13.0/24"

   tags {
    Name = "testapp-dev-euw1c-private"
  }
}

########## Create the web autoscaling group #############################
resource "aws_autoscaling_group" "web-asg" {
  name_prefix = "webASG-"
  launch_configuration = "${aws_launch_configuration.Web-lc.id}"
  availability_zones = ["${data.aws_availability_zones.available.id}"]
  vpc_zone_identifier = ["${aws_subnet.testapp-dev-euw1a-private.id}", "${aws_subnet.testapp-dev-euw1b-private.id}","${aws_subnet.testapp-dev-euw1c-private.id}"] # Specify private subnets to deploy servers into
  load_balancers = ["${aws_elb.web-lb.id}"]

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

########### Create the web server load balancer ########################
resource "aws_elb" "web-lb" {
  name_prefix = "webLB-"
  subnets = ["${aws_subnet.testapp-dev-euw1a-public.id}","${aws_subnet.testapp-dev-euw1b-public.id}","${aws_subnet.testapp-dev-euw1c-public.id}"]
  security_groups = ["${aws_security_group.weblb-sg.id}"]

  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = 8080
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:8080/"
  }
}

########### Create a DNS Alias for the LB DNS Name ########################
resource "aws_route53_record" "web-dnsalias" {
    zone_id = "Z1MCK4K7BKD9T6" # Hosted Zone in Route53 for my dev domain.
    name = "testapp.dev.j2k2lab.co.uk"
    type = "A"

    alias {
        name = "${aws_elb.web-lb.dns_name}"
        zone_id = "${aws_elb.web-lb.zone_id}"
        evaluate_target_health = true
    }
}

########### Create the web server load balancer security group #########
resource "aws_security_group" "weblb-sg" {
  name_prefix = "weblb-sg"
  vpc_id = "${aws_vpc.testapp-dev-vpc.id}"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    security_groups = ["${aws_security_group.web-sg.id}"]
  }

  lifecycle {
    create_before_destroy = "true"
  }
}

########### Create the web Security Group #############################
resource "aws_security_group" "web-sg" { # Create a security group in Lab VPC
  name_prefix = "web-sg-"
  vpc_id = "${aws_vpc.testapp-dev-vpc.id}"

  ingress { # Specify ingress rules providing cidr blocks and security group ids (if required)
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["172.16.8.0/24","172.16.9.0/24","172.16.10.0/24"]
    #security_groups = ["${aws_security_group.weblb-sg.id}"]
  }

  lifecycle {
    create_before_destroy = "true"
  }
}
