module "db" {
  source  = "terraform-aws-modules/rds/aws"

  identifier = "db"

  engine            = "postgres"
  engine_version    = "15.3"
  instance_class    = "db.t4g.micro"
  allocated_storage = 5

  db_name  = "db"
  username = "user"
  port     = "5432"

  vpc_security_group_ids = [aws_db_subnet_group.rds.id]

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = local.private_subnet_ids

  # Database Deletion Protection
  deletion_protection = true
}
