### Set a Provider ###
provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

### Get Data from other Resources ###

# Get Availability Zones AWS
data "aws_availability_zones" "available" {}

# Get Database Security Group
data "aws_security_group" "knox_db_sg" {
  tags {
    Name        = "Database SG"
  }
}


### Create the Database System ###
resource "aws_db_instance" "knox_db" {
  skip_final_snapshot     = true
  identifier              = "${var.db_identifier}"
  allocated_storage       = "${var.db_storage_size}"
  storage_type            = "${var.db_storage_type}"
  engine                  = "${var.db_engine}"
  engine_version          = "${var.db_engine_version}"
  instance_class          = "${var.db_instance_class}"
  username                = "${var.db_username}"
  password                = "${var.db_password}"
  port                    = "${var.db_port}"
  name                    = "${var.db_name}"
  apply_immediately       = true
  multi_az                = true
  backup_retention_period = "30"
  backup_window           = "21:00-21:30"
  vpc_security_group_ids  = ["${data.aws_security_group.knox_db_sg.id}"]
  maintenance_window      = "Sun:00:00-Sun:02:00"

  tags {
    Name        = "Knox Database"
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }
}
