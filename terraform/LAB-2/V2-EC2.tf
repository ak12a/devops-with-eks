terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.10.0"
    }
  }
}

provider "aws" {
    region = "us-east-1"
    profile = "arvind-devops"  
}


## Create EC2 Instances  with Security Group 

resource "aws_instance" "demo" {
    ami = "ami-09538990a0c4fe9be"
    instance_type = "t3a.micro"
    key_name = "arvind-eks"
}

resource "aws_security_group" "demo" {
  name = "SSH-terraform" # var.ec2_sg_name
  description = "Security Group Fro EC2 Instances"
  vpc_id = "vpc-1f72cd65" # var.vpc_id.id
  ingress {
    description      = "SSH from Public"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    description      = "SSH from Public"
    from_port        = 0 
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
tags = {
  Name = "Created by terraform"
}
}

