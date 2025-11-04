resource "aws_vpc" "name" {
    cidr_block = "10.0.0.0/16"
    tags = {
      Name = "cust-vpc"
    }
}

resource "aws_subnet" "subnet1" {
  vpc_id = aws_vpc.name.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "subnet2" {
    vpc_id = aws_vpc.name.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-east-1b"
    tags = {
      Name = "private-subnet"
    }
}

resource "aws_internet_gateway" "ig" {
    vpc_id = aws_vpc.name.id
    tags = {
      Name = "IG-cust"
    }
  
}

resource "aws_route_table" "pub-rt" {
    vpc_id = aws_vpc.name.id
    tags = {
      Name="pub-RT"
    }
    route = {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.ig.id
    }
}

resource "aws_route_table_association" "name" {
    subnet_id = aws_subnet.subnet1.id
    route_table_id = aws_route_table.pub-rt.id
  
}

resource "aws_security_group" "sg" {
    vpc_id = aws_vpc.name.id
    name = "allow"
    tags = {
      Name = "cust-IG"
    }
ingress {
    description = "HTTP"
    from_port = 80
    to_port = 80
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
}

ingress  {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
}
  
ingress {
    description = "HTTPS"
    from_port = 443
    to_port = 443
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
}

egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
}
}

resource "aws_instance" "pub" {
  
}