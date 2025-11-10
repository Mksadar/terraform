provider "aws" {
  region = "us-east-1"
}

resource "aws_secretsmanager_secret" "rds_credentials" {
  name = "rds-credentials"
}
resource "aws_secretsmanager_secret_version" "rds_secret_value" {
  secret_id = aws_secretsmanager_secret.rds_credentials.id

  secret_string = jsonencode({
    username = "admin"
    password = "password123"
    dbname   = "dev"
  })
}

# Create the RDS instance
resource "aws_db_instance" "my_rds" {
  identifier              = "my-mysql-db"
  engine                  = "mysql"
  instance_class          = "db.t3.micro"
  username                = "admin"
  password                = "password123"
  db_name                 = "dev"
  allocated_storage       = 20
  skip_final_snapshot     = true
  publicly_accessible     = true
}
# Key Pair
resource "aws_key_pair" "example" {
  key_name   = "task"
  public_key = file("~/.ssh/id_ed25519.pub")
}

# Example EC2 instance (replace with yours if already existing)
resource "aws_instance" "sql_runner" {
  ami                    = "ami-0c02fb55956c7d316" # Amazon Linux 2
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.example.key_name              # Replace with your key pair name
  associate_public_ip_address = true

  tags = {
    Name = "SQL Runner"
  }
}

# Deploy SQL remotely using null_resource + remote-exec
# resource "null_resource" "remote_sql_exec" {
#   depends_on = [aws_db_instance.my_rds, aws_instance.sql_runner]

#   connection {
#     type        = "ssh"
#     user        = "ec2-user"
#     private_key = file("~/.ssh/id_ed25519")   # Replace with your PEM file path
#     host        = aws_instance.sql_runner.public_ip
#   }

#   provisioner "file" {
#     source      = "init.sql"
#     destination = "/tmp/init.sql"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "mysql -h ${aws_db_instance.my_rds.address} -u ${jsondecode(aws_secretsmanager_secret_version.rds_secret_value.secret_string)["username"]} -p${jsondecode(aws_secretsmanager_secret_version.rds_secret_value.secret_string)["password"]} < /tmp/init.sql"
#     ]
#   }

#   triggers = {
#     always_run = timestamp() #trigger every time apply 
#   }
# }

# resource "null_resource" "remote_sql_exec" {
#   depends_on = [
#     aws_db_instance.mysql_rds,
#     aws_instance.ec2_instance
#   ]

#   provisioner "file" {
#     source      = "./init.sql"
#     destination = "/tmp/init.sql"

#     connection {
#       type        = "ssh"
#       user        = "ec2-user"
#       private_key = file("~/.ssh/id_ed25519.pub")
#       host        = aws_instance.sql_runner.public_ip
#     }
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "sudo yum install -y mysql",
#       "mysql -h ${aws_db_instance.mysql_rds.address} -u ${aws_db_instance.mysql_rds.username} -p${aws_db_instance.mysql_rds.password} ${aws_db_instance.mysql_rds.db_name} < /tmp/init.sql"
#     ]

#     connection {
#       type        = "ssh"
#       user        = "ec2-user"
#       private_key = file("~/.ssh/id_ed25519.pub")
#       host        = aws_instance.sql_runner.public_ip
#     }
#   }

#   triggers = {
#     run_always = timestamp()
#   }
#}

resource "null_resource" "remote_sql_exec" {
  depends_on = [
    aws_db_instance.my_rds,
    aws_secretsmanager_secret_version.rds_secret_value,
    aws_instance.sql_runner
  ]

  provisioner "file" {
    source      = "./init.sql"
    destination = "/tmp/init.sql"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/id_ed25519")
      host        = aws_instance.sql_runner.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      
      # ✅ Set region so AWS CLI works
    "echo 'export AWS_DEFAULT_REGION=us-east-1' >> ~/.bashrc",
    "source ~/.bashrc",

    # ✅ Install jq (required to parse JSON from secrets)
    "sudo yum install jq -y",
       # Update system
    "sudo yum clean metadata",
    "sudo yum -y update",

    # ✅ Install MySQL Client without using MySQL repo (NO GPG issue)
    "sudo yum install -y mariadb",


      "SECRET_VALUE=$(aws secretsmanager get-secret-value --secret-id ${aws_secretsmanager_secret.rds_credentials.id} --query SecretString --output text)",
      "DB_HOST='${aws_db_instance.my_rds.address}'",
      "DB_USER=$(echo $SECRET_VALUE | jq -r '.username')",
      "DB_PASS=$(echo $SECRET_VALUE | jq -r '.password')",
      "DB_NAME=$(echo $SECRET_VALUE | jq -r '.dbname')",
      "mysql -h $DB_HOST -u $DB_USER -p$DB_PASS $DB_NAME < /tmp/init.sql"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/id_ed25519")
      host        = aws_instance.sql_runner.public_ip
    }
  }

  triggers = {
    run_always = timestamp()
  }
}





# ADD RDS creation script only accessbale interanlly si disable public access 
# Remote provisioner server also should create insame vpc 
# enable secrets fro secret manager and call secrets into RDS for this process vpc endpoint is require or nat gateway is required to access secrets to rds internall as secremanger is not in side VPC sefrvice 