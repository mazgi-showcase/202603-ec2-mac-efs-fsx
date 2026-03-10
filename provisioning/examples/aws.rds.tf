resource "aws_db_subnet_group" "main" {
  name       = "main"
  subnet_ids = tolist(aws_subnet.private.*.id)
}

resource "aws_db_parameter_group" "custom" {
  name        = "custom-mysql8"
  family      = "mysql8.0"
  description = "MySQL 8.0 parameter group"

  parameter {
    name  = "general_log"
    value = "1"
  }

  parameter {
    name  = "slow_query_log"
    value = "1"
  }

  parameter {
    name  = "long_query_time"
    value = "0"
  }

  parameter {
    name  = "log_output"
    value = "FILE"
  }
}

resource "random_string" "db-password" {
  length  = 8
  special = false
}

resource "aws_db_instance" "main" {
  allocated_storage               = 10
  backup_retention_period         = 1
  db_name                         = "app_rds"
  db_subnet_group_name            = aws_db_subnet_group.main.name
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
  engine                          = "mysql"
  engine_version                  = "8.0"
  identifier                      = "main"
  instance_class                  = "db.t3.micro"
  password                        = random_string.db-password.result
  parameter_group_name            = aws_db_parameter_group.custom.name
  skip_final_snapshot             = true
  username                        = "admin"
  vpc_security_group_ids = [
    aws_security_group.allow-any-from-vpc.id,
  ]
}

resource "aws_db_instance" "replica" {
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
  identifier                      = "replica"
  instance_class                  = "db.t3.micro"
  parameter_group_name            = aws_db_parameter_group.custom.name
  replicate_source_db             = aws_db_instance.main.arn
  skip_final_snapshot             = true
  vpc_security_group_ids = [
    aws_security_group.allow-any-from-vpc.id,
  ]
}
