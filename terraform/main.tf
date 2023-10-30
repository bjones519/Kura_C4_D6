# configure aws provider
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = "us-east-1"

}

module "ssh_security_group" {
  name        = "ssh"
  source  = "terraform-aws-modules/security-group/aws//modules/ssh"
  version = "~> 5.0"
  vpc_id = "vpc-0a97a6a1bf23ad9ac"
  ingress_cidr_blocks = ["0.0.0.0/0"]

  tags = {
    Terraform = "true"
    Name= "Deployment6-ssh-sg-group"
  }

}

module "http_8080_security_group" {
  name        = "jenkins-server"
  source  = "terraform-aws-modules/security-group/aws//modules/http-8080"
  version = "~> 5.0"
  vpc_id = "vpc-0a97a6a1bf23ad9ac"
  ingress_cidr_blocks = ["0.0.0.0/0"]

  tags = {
    Terraform = "true"
    Name= "Deployment6-8080-sg-group"
  }

}


resource "aws_instance" "jenkins_server01" {
  ami                         = var.ami
  instance_type               = var.instance_type
  vpc_security_group_ids      = [module.ssh_security_group.security_group_id, module.http_8080_security_group.security_group_id]
  subnet_id                   = "subnet-0e6fcd89303fcf68a" #us-east-1a
  associate_public_ip_address = true
  key_name = "pub-instance"

  user_data = file("user_data.sh")

  tags = {
    Name = "deployment6-jenkinsServer"
  }

}

resource "aws_instance" "terraform_server01" {
  ami                         = var.ami
  instance_type               = var.instance_type
  vpc_security_group_ids      = [module.ssh_security_group.security_group_id]
  subnet_id                   = "subnet-07915f122c25d65ad" #us-east-1b
  associate_public_ip_address = true
  key_name = "pub-instance"

  user_data = file("user_data_agent.sh")

  tags = {
    Name = "deployment6-jenkinsAgent-terraformServer"
  }

}