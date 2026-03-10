# -----------------------------------------------------------------------------
# I4i EC2 instance (storage-optimized, local NVMe SSD)
# Placed in a private subnet; use SSM Session Manager for access.
# -----------------------------------------------------------------------------

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_security_group" "ec2_i4i" {
  name_prefix            = "${var.app_unique_id}-ec2-i4i-"
  description            = "I4i EC2 instance"
  vpc_id                 = local.persistent.vpc_id
  revoke_rules_on_delete = true

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_unique_id}-ec2-i4i"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# -----------------------------------------------------------------------------
# IAM instance profile for SSM Session Manager
# -----------------------------------------------------------------------------

resource "aws_iam_role" "ec2_i4i" {
  name = "${var.app_unique_id}-ec2-i4i"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "${var.app_unique_id}-ec2-i4i"
  }
}

resource "aws_iam_role_policy_attachment" "ec2_i4i_ssm" {
  role       = aws_iam_role.ec2_i4i.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_i4i" {
  name = "${var.app_unique_id}-ec2-i4i"
  role = aws_iam_role.ec2_i4i.name
}

# -----------------------------------------------------------------------------
# I4i instance
# -----------------------------------------------------------------------------

resource "aws_instance" "i4i" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.ec2_i4i_instance_type
  subnet_id              = local.persistent.subnet_private_a_id
  vpc_security_group_ids = [aws_security_group.ec2_i4i.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_i4i.name

  root_block_device {
    volume_type = "gp3"
    volume_size = 30
    encrypted   = true
  }

  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name = "${var.app_unique_id}-i4i"
  }
}
