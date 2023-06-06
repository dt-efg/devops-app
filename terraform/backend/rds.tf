module "rds" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "${local.app_name}-db"

  engine               = "postgres"
  engine_version       = "14"
  family               = "postgres14"
  major_engine_version = "14"
  instance_class       = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 20

  db_name  = "postgres"
  username = "postgres"
  port     = 5432

  create_random_password = true

  db_subnet_group_name   = local.database_subnet_group_name
  vpc_security_group_ids = [aws_security_group.rds.id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  tags = local.default_tags
}
