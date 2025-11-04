resource "aws_instance" "name" {
    ami = var.ami_id
    instance_type = var.instance_type
    
    tags = {
      Name = "terraform-EC2"
    }
}

resource "aws_s3_bucket" "name" {
    bucket = "hgcghxhgxsxcshxsxs"

  
}

resource "aws_vpc" "name" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name="test-VPC"
    }
}
