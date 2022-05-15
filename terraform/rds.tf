resource "aws_db_instance" "web-prod-db" {
  allocated_storage       = 20
  engine                  = "postgres"
  engine_version          = "12.10"
  instance_class          = "db.t2.micro"
  identifier              = "web-prod-db"
  backup_retention_period = 0
  db_subnet_group_name    = aws_db_subnet_group.postgres-rds-subnet-group.name
  vpc_security_group_ids  = [aws_security_group.web-prod-rds-sg.id]
  storage_type            = "gp2"
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  skip_final_snapshot     = true
}

resource "aws_db_subnet_group" "postgres-rds-subnet-group" {
  name       = "postgres-subnet"
  subnet_ids = aws_subnet.rds-subnet-private.*.id

  tags = {
    Name = "PostgreSQL DB subnet group"
  }
}

resource "aws_security_group" "web-prod-rds-sg" {
  name        = "rds-sg"
  vpc_id      = aws_vpc.web-prod-vpc.id
  description = "allow inbound access from the ECS only"

  ingress {
    protocol        = "tcp"
    from_port       = 5432
    to_port         = 5432
    security_groups = [aws_security_group.web-prod-ecs-sg.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
