variable "app_unique_id" {
  description = "Unique identifier used as a prefix for all resource names"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# -----------------------------------------------------------------------------
# Terraform remote state (persistent layer)
# -----------------------------------------------------------------------------

variable "aws_tf_state_bucket" {
  description = "S3 bucket storing the persistent layer's Terraform state"
  type        = string
}

variable "aws_tf_state_region" {
  description = "AWS region of the S3 state bucket"
  type        = string
  default     = "us-east-1"
}

# -----------------------------------------------------------------------------
# AWS Managed Microsoft AD (required by FSx for Windows)
# -----------------------------------------------------------------------------

variable "ad_admin_password" {
  description = "Admin password for AWS Managed Microsoft AD (must meet complexity requirements: 8+ chars, uppercase, lowercase, digit)"
  type        = string
  sensitive   = true
}

# -----------------------------------------------------------------------------
# FSx for Windows
# -----------------------------------------------------------------------------

variable "fsx_windows_storage_capacity" {
  description = "Storage capacity in GiB for FSx for Windows (minimum 32)"
  type        = number
  default     = 400
}

# -----------------------------------------------------------------------------
# FSx for OpenZFS
# -----------------------------------------------------------------------------

variable "fsx_openzfs_storage_capacity" {
  description = "Storage capacity in GiB for FSx for OpenZFS (minimum 64)"
  type        = number
  default     = 400
}

# -----------------------------------------------------------------------------
# WorkSpaces
# -----------------------------------------------------------------------------

variable "workspace_bundle_id" {
  description = "WorkSpaces bundle ID. Find with: aws workspaces describe-workspace-bundles --owner AMAZON"
  type        = string
}

variable "workspace_user_volume_size" {
  description = "User volume size in GiB for the WorkSpaces instance (10, 50, or 100+)"
  type        = number
  default     = 400
}

# -----------------------------------------------------------------------------
# EC2 Mac
# -----------------------------------------------------------------------------

variable "ec2_mac_instance_type" {
  description = "Instance type for the Mac EC2 instance (mac1.metal, mac2.metal, mac2-m2.metal, mac2-m2pro.metal)"
  type        = string
  default     = "mac-m4.metal"
}

variable "ec2_mac_availability_zone_id" {
  description = "AZ ID for the Mac dedicated host (e.g. use1-az4). Consistent across accounts, unlike AZ names."
  type        = string
}

variable "ec2_mac_root_volume_size" {
  description = "Root volume size in GiB for the Mac EC2 instance"
  type        = number
  default     = 200
}

# -----------------------------------------------------------------------------
# EC2 I4i
# -----------------------------------------------------------------------------

variable "ec2_i4i_instance_type" {
  description = "Instance type for the I4i EC2 instance"
  type        = string
  default     = "i4i.xlarge"
}
