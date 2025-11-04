
# Data source to fetch info of the existing RDS instance (source)
data "aws_db_instance" "source" {
  db_instance_identifier = "rds-meera"   # your existing RDS instance name
}

# Create a Read Replica
resource "aws_db_instance" "read_replica" {
  identifier              = "rds-meera-replica"
  replicate_source_db     = data.aws_db_instance.source.db_instance_identifier

  instance_class          = "db.t3.micro"   # choose your preferred size
  publicly_accessible     = false
  apply_immediately       = true

 
  deletion_protection         = false

  tags = {
    Name = "rds-meera-read-replica"
   
  }
}
