# Author Jamie McKay

# Script Goals - Build a 2 Tier Environment (web/app, Data). Load Balanced Web front end (basic HTML which reads data in a DB (simple String)) using ELB. 
# Web servers deployed across AZs in Ireland. mySQL DB using RDS.
# This script will build the infra and Ansible will create the HTML

# This script is stored in GitHub - git@github.com:d3adv3gas/aws-test.git

# Setup the Provider - Variable provied by file
provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

# Create an Ubuntu Web Server
resource "aws_instance" "Web" {
  ami           = "ami-785db401" # Machine Version
  instance_type = "t2.micro" # Instance Type
  subnet_id     = "subnet-faf02fa1" # Add to this Public subnet
  key_name      = "j2k2lablinux" # Use this key
  security_groups = ["sg-a7ec92df"] # Add to the Web Security Group
  associate_public_ip_address = "true" # Add a Public IP
  
  # Create the connection for remote execution
  connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = "${file("C:/Users/Jamie/Downloads/j2k2lablinux.pem")}"
  }

  # Copies the public key for the bastion server to the remote host
  provisioner "file" {
    source      = "E:/Scripts/Projects/terraform/bastion.txt"
    destination = "/tmp/bastion.txt"
  }
  
  # Apply the Bastion Public SSH Key to Authorized_Keys
  provisioner "remote-exec" {
    inline = ["cat /tmp/bastion.txt >> /home/ubuntu/.ssh/authorized_keys"
    ]
  } 
}

# Create an Ubuntu Bastion Server
/*#resource "aws_instance" "Bastion" {
  ami           = "ami-785db401" # Machine Version
  instance_type = "t2.micro" # Instance Type
  subnet_id     = "subnet-faf02fa1" # Add to this Public subnet
  key_name      = "j2k2lablinux" # Use this key
  security_groups = ["sg-1f8df464"] # Add to the Bastion Security Group
  associate_public_ip_address = "true" # Add a Public IP
}
*/

