########################
#  Create IAM Role
########################

resource "aws_iam_role" "example_role" {
  name = "example-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"   # Change service if needed (lambda.amazonaws.com, etc.)
        }
      }
    ]
  })
}

##############################################
#  Attach AWS Managed Policy to the IAM Role
##############################################

resource "aws_iam_role_policy_attachment" "role_managed_policy" {
  role       = aws_iam_role.example_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}
#####################################
# Instance Profile for EC2 (Mandatory)
#####################################

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "example-instance-profile"
  role = aws_iam_role.example_role.name
}

#####################################
# Launch EC2 instance with this Role
#####################################

resource "aws_instance" "ec2_with_role" {
  ami           = "ami-0c02fb55956c7d316" # example AMI (Amazon Linux 2)
  instance_type = "t3.micro"

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "ec2-with-iam-role"
  }
}

##############################
#  Create a Custom IAM Policy
##############################

resource "aws_iam_policy" "custom_policy" {
  name        = "custom-ec2-policy"
  description = "Custom policy giving EC2 list permissions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeTags"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}
########################
# fetch AWS account ID
########################
data "aws_caller_identity" "current" {}

########################
# Generate a random password
########################
resource "random_password" "console_password" {
  length           = 20
  special          = true
  override_special = "!@#$%&*()-_=+[]{}<>?"
}

########################
#  Create IAM User
########################

resource "aws_iam_user" "example_user" {
  name = "example-user"
}
########################
# Enable Console Login for IAM User
########################
resource "aws_iam_user_login_profile" "console_profile" {
  user                    = aws_iam_user.example_user.name
  password_length         = 20
  password_reset_required = true
}


###############################################
#  Attach policies to IAM User (managed + custom)
###############################################

resource "aws_iam_user_policy_attachment" "user_managed_policy" {
  user       = aws_iam_user.example_user.name
  policy_arn = "arn:aws:iam::aws:policy/IAMUserChangePassword"
}
###############################################
# Attach EC2 Full Access to IAM User
###############################################

resource "aws_iam_user_policy_attachment" "user_ec2_full_access" {
  user       = aws_iam_user.example_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

###############################################
# Attach S3 Full Access to IAM User
###############################################

resource "aws_iam_user_policy_attachment" "user_s3_full_access" {
  user       = aws_iam_user.example_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
########################
# CSV Output: Username, Password, Console Login URL
########################

resource "local_file" "iam_user_csv" {
  filename = "iam_console_users.csv"
  content  = <<EOF
UserName,Password,ConsoleSignInURL,PasswordResetRequired
${aws_iam_user.example_user.name},${aws_iam_user_login_profile.console_profile.password},https://${data.aws_caller_identity.current.account_id}.signin.aws.amazon.com/console,true
EOF

  file_permission = "0600"
}


########################
#  Create IAM Access Key
########################

resource "aws_iam_access_key" "example_user_access_key" {
  user = aws_iam_user.example_user.name
}


###########################################
# Export Access Key to CSV file
###########################################

resource "local_file" "iam_access_key_csv" {
  filename = "iam_user_credentials.csv"
  content = <<EOF
UserName,AccessKeyId,SecretAccessKey
${aws_iam_user.example_user.name},${aws_iam_access_key.example_user_access_key.id},${aws_iam_access_key.example_user_access_key.secret}
EOF
}
