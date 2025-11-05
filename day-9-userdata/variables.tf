variable "ami_id" {
    description = "passing an Ami value"
    default = "ami-07860a2d7eb515d9a"
    type = string
}

variable "instance_type" {
    description = "Passing an instance type"
    default = "t3.micro"
    type = string
  
}