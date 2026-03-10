# -----------------------------------------------------------------------------
# FSx for Windows File Server
# Requires AWS Managed Microsoft AD (see directory-service.tf).
# -----------------------------------------------------------------------------

resource "aws_security_group" "fsx_windows" {
  name_prefix            = "${var.app_unique_id}-fsx-win-"
  description            = "FSx for Windows File Server"
  vpc_id                 = local.persistent.vpc_id
  revoke_rules_on_delete = true

  ingress {
    description = "SMB from VPC"
    from_port   = 445
    to_port     = 445
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    description = "WinRM from VPC"
    from_port   = 5985
    to_port     = 5985
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
    Name = "${var.app_unique_id}-fsx-windows"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_fsx_windows_file_system" "main" {
  storage_capacity    = var.fsx_windows_storage_capacity
  storage_type        = "SSD"
  subnet_ids          = [local.persistent.subnet_private_a_id]
  throughput_capacity = 32

  active_directory_id = aws_directory_service_directory.main.id
  security_group_ids  = [aws_security_group.fsx_windows.id]

  skip_final_backup = true

  tags = {
    Name = "${var.app_unique_id}-fsx-windows"
  }
}
