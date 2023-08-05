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


## Create EC2 Instances 

resource "aws_instance" "demo" {
    ami = "ami-09538990a0c4fe9be"
    instance_type = "t3a.micro"
    key_name = "arvind-eks"
}