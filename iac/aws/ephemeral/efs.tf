# -----------------------------------------------------------------------------
# EFS — Elastic File System
# -----------------------------------------------------------------------------

resource "aws_security_group" "efs" {
  name_prefix = "${var.app_unique_id}-efs-"
  description = "EFS mount targets"
  vpc_id      = local.persistent.vpc_id

  ingress {
    description = "NFS from VPC"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_unique_id}-efs"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_efs_file_system" "main" {
  creation_token = "${var.app_unique_id}-efs"
  encrypted      = true

  performance_mode = "generalPurpose"
  throughput_mode  = "elastic"

  tags = {
    Name = "${var.app_unique_id}-efs"
  }
}

resource "aws_efs_mount_target" "private_a" {
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = local.persistent.subnet_private_a_id
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_mount_target" "private_b" {
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = local.persistent.subnet_private_b_id
  security_groups = [aws_security_group.efs.id]
}
