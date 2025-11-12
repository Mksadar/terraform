# resource "aws_instance" "name" {
#     ami = "ami-07860a2d7eb515d9a"
#     instance_type = "t3.micro"
#     count = 2
#     # tags = {
#     #   Name = "dev"
#     # }
#   tags = {
#       Name = "dev-${count.index}"
#     }
# }

variable "env" {
    type = list(string)
    default = [ "instance-1","instance-3"]
  
 }

resource "aws_instance" "name" {
    ami = "ami-07860a2d7eb515d9a"
    instance_type = "t3.micro"
    count = length(var.env)
    # tags = {
    #   Name = "dev"
    # }
  tags = {
      Name = var.env[count.index]
    }
}