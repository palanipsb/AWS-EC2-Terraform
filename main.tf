provider "aws" {
    region = var.region
  
}

terraform {
  backend "s3" {
    bucket = "teffarom-state-remote1"
    key = "state/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terralock-devops"
    encrypt = true
  }
}

data "aws_ami" "ubuntu_lts" {
    most_recent = true
    filter {
      name = "name"
      values = [ "ubuntu/images/hvm-ssd-gp3/ubuntu-*-*.04-amd64-server-*" ]
    }
    filter {
      name = "virtualization-type"
      values = [ "hvm" ]
    }
    owners = [ "099720109477" ]
}

resource "aws_vpc" "my-vpc" {
  cidr_block = var.cidr_vpc
  tags = {
    name = local.vpc_name
  }
}

resource "aws_subnet" "my-subnet" {
    vpc_id = aws_vpc.my-vpc.id
    cidr_block = var.cidr_subnet
    map_public_ip_on_launch = true
    availability_zone = var.azone

    tags = {
      name = local.subnet_name
    }
}

resource "aws_security_group" "my-sg" {
    vpc_id = aws_vpc.my-vpc.id
    name = "SG-1"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    tags = {
      name = local.sg_name
    }
}

resource "aws_internet_gateway" "my_igw" {
    vpc_id = aws_vpc.my-vpc.id
    tags = {
      name = "My-IGW"
    }
  
}

resource "aws_route_table" "my_route_table" {
    vpc_id = aws_vpc.my-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my_igw.id
    }

    tags = {
      name = "My-Route-Table"
    }
  
}

resource "aws_route_table_association" "my_route_table_association" {
    subnet_id = aws_subnet.my-subnet.id
    route_table_id = aws_route_table.my_route_table.id
}

resource "aws_instance" "my_instance" {
    ami = data.aws_ami.ubuntu_lts.id
    key_name = var.key
    subnet_id = aws_subnet.my-subnet.id
    vpc_security_group_ids = [aws_security_group.my-sg.id]
    instance_type = var.iType

    tags = {
      name = local.iname
    }
    root_block_device {
        volume_size =  15
        volume_type = "gp2"
    }  
}
