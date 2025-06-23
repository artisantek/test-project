############################
# DB Subnet Group
############################

resource "aws_db_subnet_group" "this" {
  name       = "rds-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = "rds-subnet-group"
  })
}

############################
# RDS Instance (Single-AZ, free tier)
############################

resource "aws_db_instance" "this" {
  identifier = "${var.db_name}-instance"
  engine            = "postgres"
  engine_version    = var.engine_version
  instance_class    = "db.t4g.micro"   # free tier eligible
  allocated_storage = 20
  storage_type      = "gp2"

  db_name  = var.db_name
  username = "postgres"
  password = "postgres" # For demo; should use secrets manager

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.db_sg_id]

  multi_az               = false
  publicly_accessible    = false
  skip_final_snapshot    = true

  tags = merge(var.tags, {
    Name = var.db_name
  })
} 