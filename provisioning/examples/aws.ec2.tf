data "aws_ssm_parameter" "amzn2_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_eip" "for-webap" {}

resource "aws_instance" "webap" {
  ami               = data.aws_ssm_parameter.amzn2_ami.value
  instance_type     = "t3.large"
  availability_zone = "${var.aws_default_region}a"
  subnet_id         = aws_subnet.public[0].id
  vpc_security_group_ids = [
    aws_security_group.allow-any-from-vpc.id,
    aws_security_group.allow-http-from-specific-ranges.id,
  ]

  root_block_device {
    volume_size = 40
  }

  user_data = templatefile(
    "${path.module}/aws.ec2.tftpl",
    {
      public_ip_addr_or_fqdn = aws_eip.for-webap.public_ip
      rds_url_main = format(
        "mysql://%s:%s@%s/%s",
        aws_db_instance.main.username,
        random_string.db-password.result,
        aws_db_instance.main.endpoint,
        aws_db_instance.main.db_name,
      )
      rds_url_replica = format(
        "mysql://%s:%s@%s/%s",
        aws_db_instance.replica.username,
        random_string.db-password.result,
        aws_db_instance.replica.endpoint,
        aws_db_instance.replica.db_name,
      )
    }
  )

  tags = {
    "Name" = "webap"
  }
}

resource "aws_eip_association" "for-webap" {
  instance_id   = aws_instance.webap.id
  allocation_id = aws_eip.for-webap.id
}
