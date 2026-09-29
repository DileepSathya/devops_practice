

resource "aws_db_instance" "postgres" {
  allocated_storage = 20

  engine         = "postgres"
  instance_class = "db.t3.micro"

  identifier = "my-postgres-db"
  db_name    = "form_db"
  username   = "postgres"

  skip_final_snapshot = true

  manage_master_user_password = true

  publicly_accessible = true

  tags = {
    Environment = "Dev"
    ManagedBy   = "Terraform"
  }
}