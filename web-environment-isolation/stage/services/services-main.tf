# Create an Ubuntu Web Server
resource "aws_instance" "Web" {
  count         = 1 # number of machines to build. Cannot be more than number of subnets listed in variable.tf
  ami           = "ami-785db401" # Machine Version
  instance_type = "t2.micro" # Instance Type
  key_name      = "j2k2lablinux" # Use this key
  vpc_security_group_ids = ["sg-a7ec92df"] # Add to the Web Security Group
  associate_public_ip_address = "true" # Add a Public IP
  subnet_id     = "${var.public-subnets [count.index]}" # Public subnets listed in variables.tf. 
  
  user_data = <<-EOF
    #!/bin/bash
    echo "Hello - I am server A${count.index + 1}" > index.html
    nohup busybox httpd -f -p ${var.web-ports} &
    EOF
  
  tags {
    Name = "j2k2-web-0${count.index + 1}" # Give the server a name based on the index number  
    }

  # Create the connection for remote execution
  connection {
    type     = "ssh"
    user     = "ubuntu"
    private_key = "${file("~/.ssh/j2k2lablinux.pem")}" # Linux IDE
  }

  # Copies the public key for the bastion server to the remote host
  provisioner "file" {
    source      = "~/myprojects/terraform/bastion.txt"
    destination = "/tmp/bastion.txt"
  }
  
  # Apply the Bastion Public SSH Key to Authorized_Keys
  provisioner "remote-exec" {
    inline = ["cat /tmp/bastion.txt >> /home/ubuntu/.ssh/authorized_keys"
    ]
  }
}