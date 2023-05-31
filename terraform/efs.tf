resource "aws_efs_file_system" "metabase" {
  creation_token = "metabase"
}

resource "aws_efs_mount_target" "metabase_a" {
  file_system_id  = aws_efs_file_system.metabase.id
  subnet_id       = aws_subnet.public_a.id
  security_groups = ["${aws_security_group.efs.id}"]
}

resource "aws_efs_mount_target" "metabase_c" {
  file_system_id  = aws_efs_file_system.metabase.id
  subnet_id       = aws_subnet.public_c.id
  security_groups = ["${aws_security_group.efs.id}"]
}

resource "aws_security_group" "efs" {
  name_prefix = "metabase-efs"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"
    security_groups = [
      aws_security_group.ecs.id,
    ]
  }
}
