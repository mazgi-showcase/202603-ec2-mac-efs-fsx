resource "aws_security_group" "allow-any-from-vpc" {
  name   = "allow-any-from-vpc"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      var.cidr_block_vpc,
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

resource "aws_security_group" "allow-http-from-specific-ranges" {
  name   = "allow-http-from-specific-ranges"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 3000
    to_port   = 3000
    protocol  = "tcp"
    cidr_blocks = concat(
      var.allowed_ipaddr_list,
      ["${aws_eip.for-webap.public_ip}/32"]
    )
  }

  ingress {
    from_port = 4000
    to_port   = 4000
    protocol  = "tcp"
    cidr_blocks = concat(
      var.allowed_ipaddr_list,
      ["${aws_eip.for-webap.public_ip}/32"]
    )
  }
}
