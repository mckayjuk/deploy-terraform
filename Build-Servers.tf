# Author Jamie McKay

# Script Goals - Build 2 Load Balanced Web servers which can be accessed via tha bastion over SSH. 
# Web servers deployed across AZs in Ireland. 
# This script will build the infra and Ansible will create the HTML

# This script is stored in GitHub - git@github.com:d3adv3gas/aws-test.git

# Setup the Provider - Variable provied by file
provider "aws" {
  profile   = "default"
  #access_key = "${var.access_key}" # Not required unless you do not want to use .aws credentials
  #secret_key = "${var.secret_key}" # Not required unless you do not want to use .aws credentials
  shared_credentials_file = "/Users/V3gas/.aws/credentials"
  region     = "${var.region}"
}

# Configure Terraform
terraform {
  backend "s3" { # Create an S3 bucket to store the state
    bucket  = "j2k2-tf-bucket"
    key     = "tfstate/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = "true"
  }
}

# Create an Ubuntu Web Server
resource "aws_instance" "Web" {
  count         = 3
  ami           = "ami-785db401" # Machine Version
  instance_type = "t2.micro" # Instance Type
  #subnet_id     = "subnet-faf02fa1" # Add to this Public subnet
  key_name      = "j2k2lablinux" # Use this key
  security_groups = ["sg-a7ec92df"] # Add to the Web Security Group
  associate_public_ip_address = "true" # Add a Public IP
  subnet_id       = "${element(var.public-subnets, count.index)}"
  tags {
    Name = "j2k2-web-0${count.index + 1}"
  }

  # Create the connection for remote execution
  connection {
    type     = "ssh"
    user     = "ubuntu"
    #private_key = "${file("C:/Users/Jamie/Downloads/j2k2lablinux.pem")}"
    private_key = "${file("~/Downloads/j2k2lablinux.pem")}"
  }

  # Copies the public key for the bastion server to the remote host
  provisioner "file" {
    #source      = "E:/Scripts/Projects/terraform/bastion.txt"
    source      = "/Users/V3gas/myprojects/bastion.txt"
    destination = "/tmp/bastion.txt"
  }
  
  # Apply the Bastion Public SSH Key to Authorized_Keys
  provisioner "remote-exec" {
    inline = ["cat /tmp/bastion.txt >> /home/ubuntu/.ssh/authorized_keys"
    ]
  }
}
