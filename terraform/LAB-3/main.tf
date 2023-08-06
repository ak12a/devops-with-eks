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

## In This Video we will learn how to create VPC ###
#############################################################
#################       VPC       ###########################
#############################################################
resource "aws_vpc" "devops-vpc" {
   cidr_block     = "192.168.0.0/16"
   instance_tenancy     = "default"
   enable_dns_support   = true
   enable_dns_hostnames = true
   tags = {
     Name = "Devop-VPC"
   }
}


###############################################################
##############         Subnets     ############################
###############################################################

resource "aws_subnet" "Public-subnet" {
   vpc_id = aws_vpc.devops-vpc.id 
   availability_zone = "us-east-1a"
   cidr_block = "192.168.0.0/24"
   map_public_ip_on_launch = "true"
   tags = {
     Name = lower("Devops-Sub-Pub")
   }
  
}

resource "aws_subnet" "Private-subnet" {
   vpc_id = aws_vpc.devops-vpc.id 
   availability_zone = "us-east-1b"
   cidr_block = "192.168.1.0/24"
   map_public_ip_on_launch = "false"
   tags = {
     Name = lower("Devops-Sub-Priv")
   }
  
}

######################################################
################ Internate Gateway ###################
######################################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.devops-vpc.id
  depends_on = [aws_vpc.devops-vpc]
  tags = {
    Name = "Devops-IGW"
  }
}

# resource "aws_internet_gateway_attachment" "igw-attach" {
#   vpc_id = aws_vpc.devops-vpc.id
#   internet_gateway_id = aws_internet_gateway.igw.id
# }

######################################################
################ Route Table      ####################
######################################################

resource "aws_route_table" "pub-rt" {
  vpc_id = aws_vpc.devops-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = lower("Public-Route")
  }
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.devops-vpc.id

#   route {
#     cidr_block = "192.168.0.0/16"
#     local_gateway_id = "local"
#   }


  tags = {
    Name = lower("Private-Route")
  }
}

####################################################
############ RT Assocaiation #######################
####################################################

resource "aws_route_table_association" "rt-sssocaiation-pub" {
  route_table_id               = aws_route_table.pub-rt.id 
  subnet_id                    = aws_subnet.Public-subnet.id
}

resource "aws_route_table_association" "rt-assocaiation-private" {
  route_table_id               = aws_route_table.private-rt.id 
  subnet_id                    = aws_subnet.Private-subnet.id
}

