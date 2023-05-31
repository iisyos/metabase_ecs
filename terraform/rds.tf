data "aws_ssm_parameter" "rds_username" {
  name = "/metabase/rds/mysql/username"
}

data "aws_ssm_parameter" "rds_password" {
  name            = "/metabase/rds/mysql/password"
  with_decryption = true
}

resource "aws_security_group" "db" {
  name_prefix = "metabase-db"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    security_groups = [
      aws_security_group.ecs.id,
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "rds_instance" {
  identifier              = "myrds"
  db_name                 = "myrdsinstance"
  engine                  = "mysql"
  engine_version          = "5.7"
  instance_class          = "db.t2.micro"
  username                = data.aws_ssm_parameter.rds_username.value
  password                = data.aws_ssm_parameter.rds_password.value
  allocated_storage       = 10
  storage_type            = "gp2"
  backup_retention_period = 7
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.db.id]
  skip_final_snapshot     = true
}