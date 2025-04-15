#locals {
 # name = "kuber-lab01"
#}
provider "aws" {
    region = "eu-west-2"
  
}

# Creating RSA private key
resource "tls_private_key" "keypair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
# Creating private key locally
resource "local_file" "keypair" {
  content         = tls_private_key.keypair.private_key_pem
  filename        = "kuber01-key.pem"
  file_permission = "600"
}
#Create and register the public key in aws
resource "aws_key_pair" "keypair" {
  key_name   = "kuber01-pub-key"
  public_key = tls_private_key.keypair.public_key_openssh
}
# Creating  Master Security Group
resource "aws_security_group" "master-sg" {
  name        = "master-sg"
  description = "Allow specific inbound and outbound traffic"
  ingress {
    description = "Kubernetics API server"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "master-sg"
  }
}

# Creating Ec2 for Master Node
resource "aws_instance" "master" {
  ami                         = "ami-0a94c8e4ca2674d5a" #ubuntu
  instance_type               = "t3.medium"
  key_name                    = aws_key_pair.keypair.id
  vpc_security_group_ids      = [aws_security_group.master-sg.id]
  associate_public_ip_address = true
  user_data                   = file("./master-userdata.sh")

  tags = {
    Name = "master-Node"
  }
}

# Creating Ec2 for Worker
resource "aws_instance" "worker" {
  ami                         = "ami-0a94c8e4ca2674d5a" #ubuntu
  count                       = 2
  instance_type               = "t3.medium"
  key_name                    = aws_key_pair.keypair.id
  vpc_security_group_ids      = [aws_security_group.master-sg.id]
  associate_public_ip_address = true
  user_data                   = file("./worker-userdata.sh")

  tags = {
    Name = "worker-node-${count.index}"
  }
}

#To print out public ip
output "master_ip" {
  value = aws_instance.master.public_ip
}

output "workers_ip" {
  value = aws_instance.worker.*.public_ip

}