# マスターパスワードはコードに含めず、ランダム生成する。
# Secrets Managerへの登録・ECSタスクへの注入は別モジュールで行う想定（#36）。
resource "random_password" "master" {
  length  = 24
  special = false
}

resource "aws_db_instance" "main" {
  identifier     = "${var.name}-db"
  engine         = "postgres"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage = var.allocated_storage

  db_name  = var.db_name
  username = var.username
  password = random_password.master.result
  port     = var.port

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.db.id]

  publicly_accessible = false
  skip_final_snapshot = true
  apply_immediately   = true

  storage_encrypted       = true
  backup_retention_period = 7
}
