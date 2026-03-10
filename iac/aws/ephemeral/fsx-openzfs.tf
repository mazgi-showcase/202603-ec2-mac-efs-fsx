# -----------------------------------------------------------------------------
# FSx for OpenZFS
# -----------------------------------------------------------------------------

resource "aws_security_group" "fsx_openzfs" {
  name_prefix = "${var.app_unique_id}-fsx-zfs-"
  description = "FSx for OpenZFS"
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
    Name = "${var.app_unique_id}-fsx-openzfs"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_fsx_openzfs_file_system" "main" {
  storage_capacity    = var.fsx_openzfs_storage_capacity
  storage_type        = "SSD"
  subnet_ids          = [local.persistent.subnet_private_a_id]
  deployment_type     = "SINGLE_AZ_1"
  throughput_capacity = 64

  security_group_ids = [aws_security_group.fsx_openzfs.id]

  skip_final_backup = true

  root_volume_configuration {
    data_compression_type = "LZ4"
  }

  tags = {
    Name = "${var.app_unique_id}-fsx-openzfs"
  }
}
