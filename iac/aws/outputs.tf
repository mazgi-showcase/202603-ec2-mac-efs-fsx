# -----------------------------------------------------------------------------
# VPC networking (referenced by ephemeral layer)
# -----------------------------------------------------------------------------

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "subnet_public_a_id" {
  description = "Public subnet A ID"
  value       = aws_subnet.public_a.id
}

output "subnet_public_b_id" {
  description = "Public subnet B ID"
  value       = aws_subnet.public_b.id
}

output "subnet_private_a_id" {
  description = "Private subnet A ID"
  value       = aws_subnet.private_a.id
}

output "subnet_private_b_id" {
  description = "Private subnet B ID"
  value       = aws_subnet.private_b.id
}

output "private_route_table_id" {
  description = "Private route table ID"
  value       = aws_route_table.private.id
}
