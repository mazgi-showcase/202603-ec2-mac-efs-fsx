# # -----------------------------------------------------------------------------
# # EC2 Mac instance
# # Requires a dedicated host (minimum 24-hour allocation).
# # mac-m4.metal is only available in specific AZs — set var.ec2_mac_availability_zone.
# # Placed in a private subnet; use SSM Session Manager for access.
# # -----------------------------------------------------------------------------

# data "aws_ami" "macos" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["amzn-ec2-macos-*"]
#   }

#   filter {
#     name   = "architecture"
#     values = [var.ec2_mac_instance_type == "mac1.metal" ? "x86_64_mac" : "arm64_mac"]
#   }
# }

# # Resolve AZ ID (e.g. use1-az4) to AZ name (e.g. us-east-1a)
# data "aws_availability_zone" "mac" {
#   zone_id = var.ec2_mac_availability_zone_id
# }

# # Look up a private subnet in the specified AZ
# data "aws_subnets" "private_in_mac_az" {
#   filter {
#     name   = "vpc-id"
#     values = [local.persistent.vpc_id]
#   }
#   filter {
#     name   = "availability-zone"
#     values = [data.aws_availability_zone.mac.name]
#   }
#   filter {
#     name   = "subnet-id"
#     values = [local.persistent.subnet_private_a_id, local.persistent.subnet_private_b_id]
#   }
# }

# resource "aws_security_group" "ec2_mac" {
#   name_prefix = "${var.app_unique_id}-ec2-mac-"
#   description = "EC2 Mac instance"
#   vpc_id      = local.persistent.vpc_id

#   ingress {
#     description = "SSH from VPC"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["10.0.0.0/16"]
#   }

#   ingress {
#     description = "VNC from VPC"
#     from_port   = 5900
#     to_port     = 5900
#     protocol    = "tcp"
#     cidr_blocks = ["10.0.0.0/16"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "${var.app_unique_id}-ec2-mac"
#   }

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# # -----------------------------------------------------------------------------
# # IAM instance profile for SSM Session Manager
# # -----------------------------------------------------------------------------

# resource "aws_iam_role" "ec2_mac" {
#   name = "${var.app_unique_id}-ec2-mac"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Principal = {
#         Service = "ec2.amazonaws.com"
#       }
#       Action = "sts:AssumeRole"
#     }]
#   })

#   tags = {
#     Name = "${var.app_unique_id}-ec2-mac"
#   }
# }

# resource "aws_iam_role_policy_attachment" "ec2_mac_ssm" {
#   role       = aws_iam_role.ec2_mac.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
# }

# resource "aws_iam_instance_profile" "ec2_mac" {
#   name = "${var.app_unique_id}-ec2-mac"
#   role = aws_iam_role.ec2_mac.name
# }

# # -----------------------------------------------------------------------------
# # Dedicated host (required for Mac instances)
# # -----------------------------------------------------------------------------

# resource "aws_ec2_host" "mac" {
#   instance_type     = var.ec2_mac_instance_type
#   availability_zone = data.aws_availability_zone.mac.name
#   auto_placement    = "on"

#   tags = {
#     Name = "${var.app_unique_id}-mac-host"
#   }
# }

# # -----------------------------------------------------------------------------
# # Mac instance
# # -----------------------------------------------------------------------------

# resource "aws_instance" "mac" {
#   ami                    = data.aws_ami.macos.id
#   instance_type          = var.ec2_mac_instance_type
#   subnet_id              = data.aws_subnets.private_in_mac_az.ids[0]
#   vpc_security_group_ids = [aws_security_group.ec2_mac.id]
#   iam_instance_profile   = aws_iam_instance_profile.ec2_mac.name
#   host_id                = aws_ec2_host.mac.id

#   root_block_device {
#     volume_type = "gp3"
#     volume_size = var.ec2_mac_root_volume_size
#     encrypted   = true
#   }

#   metadata_options {
#     http_tokens = "required"
#   }

#   tags = {
#     Name = "${var.app_unique_id}-mac"
#   }
# }
