

provider "aws" {
  region = var.region
 # profile = "dev"
}

module "vpc" {
  source              = "../../modules/vpc"
  cidr_block          = var.vpc_cidr          # ✅ Correct name
   main                = var.main 
  availability_zone   = var.availability_zone  
  availability_zone2   = var.availability_zone2     # ✅ Correct name
  public_subnet_cidr  = var.public_subnet_cidr 
  public_subnet2_cidr  = var.public_subnet2_cidr    # ✅ Correct name
  env                 = var.env
}

module "ec2" {
  source        = "../../modules/ec2"
  ami_id = var.ami_id
  instance_type = var.instance_type
  env           = var.env
  subnet_1_id     = module.vpc.subnet_1_id
  
}

module "rds" {
  source         = "../../modules/rds"
  subnet_1_id      = module.vpc.subnet_1_id
  subnet_2_id      = module.vpc.subnet_2_id
  instance_class = "db.t3.micro"
  db_name        = "mydb"
  db_user        = "admin"
  db_password    = "Admin12345"
}

module "s3" {
    source = "../../modules/s3"
    bucket = "buckett-mssss-mkss"
  
}