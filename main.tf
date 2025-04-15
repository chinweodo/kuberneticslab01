#locals {
 # name = "kuber-lab01"
#}

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
  #ingress {
   # description = "Kubernetics API server"
   # from_port   = 6443
   # to_port     = 6443
    #protocol    = "tcp"
    #cidr_blocks = ["0.0.0.0/0"]
  #}
  
   #ingress {
    #description = "ssh"
    #from_port   = 22
    #to_port     = 22
    #protocol    = "tcp"
    #cidr_blocks = ["0.0.0.0/0"]
  #}
   #ingress {
   # description = "client communication"
   # from_port   = 2379
    #to_port     = 2380
    #protocol    = "tcp"
    #cidr_blocks = ["0.0.0.0/0"]
  #}
   #ingress {
    #description = "Kublet API"
    #from_port   = 10250
    #to_port     = 10250
    #protocol    = "tcp"
    #cidr_blocks = ["0.0.0.0/0"]
  #}
   #ingress {
   # description = "Kube-scheduler"
    #from_port   = 10251
   # to_port     = 10251
    #protocol    = "tcp"
    #cidr_blocks = ["0.0.0.0/0"]
  #}
  #ingress {
   # description = "Kube-controller-manager"
   # from_port   = 10252
   # to_port     = 10252
   # protocol    = "tcp"
   # cidr_blocks = ["0.0.0.0/0"]
  #}
  # Egress rule: allow all outbound traffic
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

# Creating  Worker Security Group
#resource "aws_security_group" "worker-sg" {
 # name        = "worker-sg"
 # description = "Allow specific inbound and outbound traffic"

 # Ingress rule:  allow specific ports for kubernetics components
 # ingress {
   # description = "Kublet API"
   # from_port   = 10250
   # to_port     = 10250
   # protocol    = "tcp"
    #cidr_blocks = ["0.0.0.0/0"]
 # }
  
  # ingress {
   # description = "ssh"
   # from_port   = 22
    #to_port     = 22
    #protocol    = "tcp"
   # cidr_blocks = ["0.0.0.0/0"]
  #}
   #ingress {
   # description = "NodePort services"
   # from_port   = 30000
   # to_port     = 32767
   # protocol    = "tcp"
   # cidr_blocks = ["0.0.0.0/0"]
  #}
   #ingress {
   # description = "Weave net"
   # from_port   = 6783
   # to_port     = 6784
   # protocol    = "tcp"
   # cidr_blocks = ["0.0.0.0/0"]
  #}
  # ingress {
   # description = "Kubelet Read-only port"
   # from_port   = 10255
    #to_port     = 10255
    #protocol    = "tcp"
    #cidr_blocks = ["0.0.0.0/0"]
  #}
  #ingress {
   # description = "DNS Resolution"
    #from_port   = 53
   # to_port     = 53
   # protocol    = "tcp"
    #cidr_blocks = ["0.0.0.0/0"]
 # }

  #ingress {
   # description = "VXLAN (Overlay Nework Traffic)"
   # from_port   = 4789
   # to_port     = 4789
    #protocol    = "tcp"
    #cidr_blocks = ["0.0.0.0/0"]
  #}

  # Egress rule: allow all outbound traffic
  #egress {
   # from_port   = 0
   # to_port     = 0
   # protocol    = "-1"
   # cidr_blocks = ["0.0.0.0/0"]
 # }

 # tags = {
  #  Name = "worker-sg"
 # }
#}

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
