resource "google_service_account" "github-actions-owner" {
  account_id = "github-actions-owner"
}

resource "google_service_account_key" "github-actions-owner" {
  service_account_id = google_service_account.github-actions-owner.name
}

resource "google_project_iam_member" "github-actions-owner-project-owner" {
  project = var.gcp_project_id
  role    = "roles/owner"
  member  = format("serviceAccount:%s", google_service_account.github-actions-owner.email)
}

resource "google_project_iam_member" "github-actions-owner-storage-admin" {
  project = var.gcp_project_id
  role    = "roles/storage.admin"
  member  = format("serviceAccount:%s", google_service_account.github-actions-owner.email)
}
