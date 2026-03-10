resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block_vpc
  enable_dns_hostnames = true
}

resource "aws_vpc_dhcp_options" "main" {
  domain_name_servers = ["AmazonProvidedDNS"]
}

resource "aws_vpc_dhcp_options_association" "main" {
  vpc_id          = aws_vpc.main.id
  dhcp_options_id = aws_vpc_dhcp_options.main.id
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_eip" "for-nat-gateway" {
  count = length(var.cidr_blocks_public_subnets)
}

resource "aws_nat_gateway" "main" {
  count = length(var.cidr_blocks_public_subnets)

  depends_on = [
    aws_internet_gateway.main,
    aws_eip.for-nat-gateway,
  ]

  allocation_id = element(aws_eip.for-nat-gateway.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
}

resource "aws_subnet" "public" {
  count = length(var.cidr_blocks_public_subnets)

  vpc_id     = aws_vpc.main.id
  cidr_block = element(keys(var.cidr_blocks_public_subnets), count.index)
  availability_zone = format(
    "%s%s",
    data.aws_region.current.region,
    lookup(var.cidr_blocks_public_subnets, element(keys(var.cidr_blocks_public_subnets), count.index))
  )
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  count = length(var.cidr_blocks_private_subnets)

  vpc_id     = aws_vpc.main.id
  cidr_block = element(keys(var.cidr_blocks_private_subnets), count.index)
  availability_zone = format(
    "%s%s",
    data.aws_region.current.region,
    lookup(var.cidr_blocks_private_subnets, element(keys(var.cidr_blocks_private_subnets), count.index))
  )
  map_public_ip_on_launch = false
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_main_route_table_association" "main" {
  vpc_id         = aws_vpc.main.id
  route_table_id = aws_route_table.main.id
}

resource "aws_route_table" "to-nat-gateway-for-private-subnets" {
  count = length(var.cidr_blocks_private_subnets)

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.main.*.id, count.index)
  }
}

resource "aws_route_table_association" "to-nat-gateway-for-private-subnets" {
  count = length(var.cidr_blocks_private_subnets)

  route_table_id = element(aws_route_table.to-nat-gateway-for-private-subnets.*.id, count.index)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
}
