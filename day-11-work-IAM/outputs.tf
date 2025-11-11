output "access_key_id" {
  value = aws_iam_access_key.example_user_access_key.id
}

output "secret_access_key" {
  value     = aws_iam_access_key.example_user_access_key.secret
  sensitive = true
}

output "user_name" {
  value = aws_iam_user.example_user.name
}
