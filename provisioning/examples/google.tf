# https://www.terraform.io/docs/providers/google/guides/version_3_upgrade.html#google_project_services-has-been-removed-from-the-provider
resource "google_project_service" "service" {
  for_each = toset([
    "cloudresourcemanager.googleapis.com",
    "dns.googleapis.com",
    "iam.googleapis.com",
  ])

  service = each.key

  project            = var.gcp_project_id
  disable_on_destroy = false
}
