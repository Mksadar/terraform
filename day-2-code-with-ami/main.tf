resource "aws_instance" "name" {
    ami = var.ami_id
    instance_type = var.instance_type
    subnet_id = aws_subnet.name.id
    tags = {
      Name = "terraform-EC2"
    }
}

resource "aws_vpc" "name" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name="test-VPC"
    }
}

resource "aws_subnet" "name" {
    vpc_id = aws_vpc.name.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    tags = {
      Name= "subnet-1"
    }
}

resource "aws_subnet" "name1" {
    vpc_id = aws_vpc.name.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1b"
    tags = {
      Name = "subnet-2"
    }
  
}