terraform {
  backend "s3" {
    bucket                  = "terraform-s3-state-0223"
    key                     = "my-terraform-project"
    region                  = "us-east-1"
    shared_credentials_file = "~/.aws/credentials"
  }
}

provider "aws" {
  region = "us-west-1"
}

resource "aws_s3_bucket" "New_bucket" {
  bucket = "ENTER YOUR BUCKET NAME" #kindly add bucket name
  acl    = "private"

  tags = {
    Name = "myBucketTagName"
  }
}

module "vpc" {
  source        = "./vpc"
  vpc_cidr      = "10.0.0.0/16"
  public_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]

}
/*
module "ec2" {
  source         = "./ec2"
  instance_type  = "t2.micro"
  security_group = module.vpc.security_group
  subnets        = module.vpc.public_subnets
}
*/

module "alb" {
  source = "./alb"
  vpc_id = module.vpc.vpc_id

  //instance1_id = module.ec2.instance1_id
  //instance2_id = module.ec2.instance2_id

  subnet1 = module.vpc.subnet1
  subnet2 = module.vpc.subnet2
}




module "auto_scaling" {
  source           = "./autoscalling"
  vpc_id           = module.vpc.vpc_id
  subnet1          = module.vpc.subnet1
  subnet2          = module.vpc.subnet2
  target_group_arn = module.alb.alb_target_group_arn
 
}


module "rds" {
  source      = "./rds"
  db_instance = "db.t3.micro"
  rds_subnet1 = module.vpc.private_subnet1
  rds_subnet2 = module.vpc.private_subnet2
  vpc_id      = module.vpc.vpc_id
}

