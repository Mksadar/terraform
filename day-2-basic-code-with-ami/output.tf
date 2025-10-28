output "publicIP" {
    value = aws_instance.name.public_ip
}

output "availability_zone" {
    value = aws_instance.name.availability_zone
}

output "privateIP" {
  value = aws_instance.name.private_ip
}