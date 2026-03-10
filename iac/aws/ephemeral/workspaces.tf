# -----------------------------------------------------------------------------
# Amazon WorkSpaces (Linux)
# Uses the Managed Microsoft AD created in directory-service.tf.
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# workspaces_DefaultRole — required by the WorkSpaces service.
# AWS creates this automatically via the Console, but not via API/Terraform.
# -----------------------------------------------------------------------------

resource "aws_iam_role" "workspaces_default" {
  name = "workspaces_DefaultRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "workspaces.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "workspaces_default_service_access" {
  role       = aws_iam_role.workspaces_default.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonWorkSpacesServiceAccess"
}

resource "aws_iam_role_policy_attachment" "workspaces_default_self_service_access" {
  role       = aws_iam_role.workspaces_default.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonWorkSpacesSelfServiceAccess"
}

# -----------------------------------------------------------------------------

resource "aws_workspaces_directory" "main" {
  directory_id = aws_directory_service_directory.main.id

  depends_on = [
    aws_iam_role_policy_attachment.workspaces_default_service_access,
    aws_iam_role_policy_attachment.workspaces_default_self_service_access,
  ]

  subnet_ids = [
    local.persistent.subnet_private_a_id,
    local.persistent.subnet_private_b_id,
  ]

  self_service_permissions {
    change_compute_type  = false
    increase_volume_size = false
    rebuild_workspace    = true
    restart_workspace    = true
    switch_running_mode  = false
  }

  workspace_creation_properties {
    enable_internet_access              = true
    enable_maintenance_mode             = true
    user_enabled_as_local_administrator = true
  }

  tags = {
    Name = "${var.app_unique_id}-workspaces"
  }
}

resource "aws_workspaces_workspace" "linux" {
  directory_id = aws_workspaces_directory.main.id
  bundle_id    = var.workspace_bundle_id
  user_name    = "Admin"

  root_volume_encryption_enabled = true
  user_volume_encryption_enabled = true
  volume_encryption_key          = "alias/aws/workspaces"

  workspace_properties {
    compute_type_name                         = "VALUE"
    running_mode                              = "AUTO_STOP"
    running_mode_auto_stop_timeout_in_minutes = 60
    # Valid combinations: (80|10), (80|50), (80|100), (175+|100+)
    root_volume_size_gib = 175
    user_volume_size_gib = var.workspace_user_volume_size
  }

  tags = {
    Name = "${var.app_unique_id}-workspace-linux"
  }
}
