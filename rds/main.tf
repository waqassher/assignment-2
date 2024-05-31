provider "aws" {
  region = "us-west-1"
}

/*resource "random_password" "password" {
  length  = 16
  special = true
}
resource "random_password" "db_master_pass" {
  length            = 40
  special           = true
  min_special       = 5
  override_special  = "!#$%^&*()-_=+[]{}<>:?"
  keepers           = {
    pass_version  = 1
  }
}*/

resource "aws_db_instance" "my-test-sql" {
  instance_class          = var.db_instance
  engine                  = "mysql"
  engine_version          = "5.7"
  multi_az                = true
  storage_type            = "gp2"
  allocated_storage       = 20
  name                    = "mytestrds"
  username                = local.db_creds.username
  password                = local.db_creds.password
  apply_immediately       = "true"
  backup_retention_period = 10
  backup_window           = "09:46-10:16"
  db_subnet_group_name    = aws_db_subnet_group.my-rds-db-subnet.name
  vpc_security_group_ids  = ["${aws_security_group.my-rds-sg.id}"]
  skip_final_snapshot = true
}

resource "aws_db_subnet_group" "my-rds-db-subnet" {
  name       = "my-rds-db-subnet"
  subnet_ids = ["${var.rds_subnet1}", "${var.rds_subnet2}"]
}

resource "aws_security_group" "my-rds-sg" {
  name   = "my-rds-sg"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "my-rds-sg-rule" {
  from_port         = 3306
  protocol          = "tcp"
  security_group_id = aws_security_group.my-rds-sg.id
  to_port           = 3306
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "outbound_rule" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.my-rds-sg.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}
