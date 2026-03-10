# -----------------------------------------------------------------------------
# EFS
# -----------------------------------------------------------------------------

output "efs_file_system_id" {
  description = "EFS file system ID"
  value       = aws_efs_file_system.main.id
}

output "efs_dns_name" {
  description = "EFS DNS name for mounting"
  value       = aws_efs_file_system.main.dns_name
}

# -----------------------------------------------------------------------------
# FSx for Windows
# -----------------------------------------------------------------------------

output "fsx_windows_file_system_id" {
  description = "FSx for Windows file system ID"
  value       = aws_fsx_windows_file_system.main.id
}

output "fsx_windows_dns_name" {
  description = "FSx for Windows DNS name for SMB access"
  value       = aws_fsx_windows_file_system.main.dns_name
}

output "ad_directory_id" {
  description = "AWS Managed Microsoft AD directory ID"
  value       = aws_directory_service_directory.main.id
}

output "ad_dns_ip_addresses" {
  description = "AWS Managed Microsoft AD DNS IP addresses"
  value       = aws_directory_service_directory.main.dns_ip_addresses
}

# -----------------------------------------------------------------------------
# FSx for OpenZFS
# -----------------------------------------------------------------------------

output "fsx_openzfs_file_system_id" {
  description = "FSx for OpenZFS file system ID"
  value       = aws_fsx_openzfs_file_system.main.id
}

output "fsx_openzfs_dns_name" {
  description = "FSx for OpenZFS DNS name for NFS access"
  value       = aws_fsx_openzfs_file_system.main.dns_name
}

# -----------------------------------------------------------------------------
# WorkSpaces
# -----------------------------------------------------------------------------

output "workspace_linux_id" {
  description = "Amazon WorkSpaces Linux workspace ID"
  value       = aws_workspaces_workspace.linux.id
}

output "workspace_linux_ip_address" {
  description = "Amazon WorkSpaces Linux IP address"
  value       = aws_workspaces_workspace.linux.ip_address
}

# -----------------------------------------------------------------------------
# EC2 I4i
# -----------------------------------------------------------------------------

output "ec2_i4i_instance_id" {
  description = "I4i EC2 instance ID"
  value       = aws_instance.i4i.id
}

output "ec2_i4i_private_ip" {
  description = "I4i EC2 private IP address"
  value       = aws_instance.i4i.private_ip
}

# # -----------------------------------------------------------------------------
# # EC2 Mac
# # -----------------------------------------------------------------------------

# output "ec2_mac_instance_id" {
#   description = "Mac EC2 instance ID"
#   value       = aws_instance.mac.id
# }

# output "ec2_mac_private_ip" {
#   description = "Mac EC2 private IP address"
#   value       = aws_instance.mac.private_ip
# }

# output "ec2_mac_host_id" {
#   description = "Mac dedicated host ID"
#   value       = aws_ec2_host.mac.id
# }
