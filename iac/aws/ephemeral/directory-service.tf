# -----------------------------------------------------------------------------
# AWS Managed Microsoft AD
# Used by FSx for Windows and WorkSpaces.
# -----------------------------------------------------------------------------

resource "aws_directory_service_directory" "main" {
  name     = "${var.app_unique_id}.local"
  password = var.ad_admin_password
  edition  = "Standard"
  type     = "MicrosoftAD"

  vpc_settings {
    vpc_id = local.persistent.vpc_id
    subnet_ids = [
      local.persistent.subnet_private_a_id,
      local.persistent.subnet_private_b_id,
    ]
  }

  tags = {
    Name = "${var.app_unique_id}-ad"
  }
}
