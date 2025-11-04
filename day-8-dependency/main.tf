resource "aws_vpc" "name" {
    cidr_block = "10.0.0.0/24"
    tags = {
        Name="test"
    }

    depends_on = [ aws_s3_bucket.name ]
  
}

resource "aws_s3_bucket" "name" {
    bucket = "mksssssbuckettt"
  
}