# configure aws provider
provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = "us-east-1"

}

#VPC in us-east-1
module "vpc-east" {
  source = "terraform-aws-modules/vpc/aws"

  name = "Deployment6-us-east-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  #private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  tags = {
    Terraform = "true"
  }
}

#VPC in us-west-2
module "vpc-west" {
  source = "terraform-aws-modules/vpc/aws"

  name = "Deployment6-us-west-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b"]
  #private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  tags = {
    Terraform = "true"
  }
}

#SSH Security Group us-east VPC
module "ssh_security_group-east" {
  name        = "ssh"
  source  = "terraform-aws-modules/security-group/aws//modules/ssh"
  version = "~> 5.0"
  vpc_id = module.vpc-east.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]

  tags = {
    Terraform = "true"
    Name= "Deployment5.1-ssh-sg-group"
  }

}

#Port 8000 Security group us-east VPC
module "app_service_sg-east" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "app-service"
  description = "Security group for application with custom port 8000 open within VPC"
  vpc_id      = module.vpc-east.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 8000
      to_port     = 8000
      protocol    = "tcp"
      description = " Gunicorn Application port"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = -1
      to_port     = -1
      protocol    = "-1"
      description = "All protocols"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

#SSH Security Group us-west VPC
module "ssh_security_group-west" {
  name        = "ssh"
  source  = "terraform-aws-modules/security-group/aws//modules/ssh"
  version = "~> 5.0"
  vpc_id = module.vpc-west.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]

  tags = {
    Terraform = "true"
    Name= "Deployment5.1-ssh-sg-group"
  }

}

#Port 8000 Security group us-west VPC
module "app_service_sg-west" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "app-service"
  description = "Security group for application with custom port 8000 open within VPC"
  vpc_id      = module.vpc-west.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 8000
      to_port     = 8000
      protocol    = "tcp"
      description = " Gunicorn Application port"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = -1
      to_port     = -1
      protocol    = "-1"
      description = "All protocols"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

#App servers in us-east-1
resource "aws_instance" "app_server01-east" {
  ami                         = var.ami
  instance_type               = var.instance_type
  vpc_security_group_ids      = [module.ssh_security_group-east.security_group_id,module.app_service_sg-east.security_group_id]
  subnet_id                   = module.vpc-east.public_subnets[0]
  associate_public_ip_address = true
  key_name = "pub-instance"
  #depends_on = [aws_internet_gateway.gw]

  user_data = file("user_data.sh")

  tags = {
    Name = "deployment6-appSever"
  }

}

resource "aws_instance" "app_server02-east" {
  ami                         = var.ami
  instance_type               = var.instance_type
  vpc_security_group_ids      = [module.ssh_security_group-east.security_group_id,module.app_service_sg-east.security_group_id]
  subnet_id                   = module.vpc-east.public_subnets[1]
  associate_public_ip_address = true
  key_name = "pub-instance"
  #depends_on = [aws_internet_gateway.gw]

  user_data = file("user_data.sh")

  tags = {
    Name = "deployment6-applicationServer02-east"
  }

}

#App servers in us-west-2
resource "aws_instance" "app_server01-west" {
  ami                         = var.ami
  instance_type               = var.instance_type
  vpc_security_group_ids      = [module.ssh_security_group-west.security_group_id,module.app_service_sg-west.security_group_id]
  subnet_id                   = module.vpc-west.public_subnets[1]
  associate_public_ip_address = true
  key_name = "pub-instance"
  #depends_on = [aws_internet_gateway.gw]

  user_data = file("user_data.sh")

  tags = {
    Name = "deployment6-applicationServer01-west"
  }

}

resource "aws_instance" "app_server02-west" {
  ami                         = var.ami
  instance_type               = var.instance_type
  vpc_security_group_ids      = [module.ssh_security_group-west.security_group_id,module.app_service_sg-west.security_group_id]
  subnet_id                   = module.vpc-west.public_subnets[1]
  associate_public_ip_address = true
  key_name = "pub-instance"
  #depends_on = [aws_internet_gateway.gw]

  user_data = file("user_data.sh")

  tags = {
    Name = "deployment6-applicationServer02-west"
  }

}