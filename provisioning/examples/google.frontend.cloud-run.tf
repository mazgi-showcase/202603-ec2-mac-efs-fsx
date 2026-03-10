resource "google_cloud_run_domain_mapping" "frontend" {
  name     = "frontend.${var.base_dnsdomain}"
  location = var.gcp_default_region
  metadata {
    namespace = var.gcp_project_id
    annotations = {
      "run.googleapis.com/launch-stage" = "BETA"
    }
  }
  spec {
    route_name = google_cloud_run_service.frontend.name
  }
  lifecycle {
    ignore_changes = [metadata]
  }
}

resource "google_cloud_run_service" "frontend" {
  name     = "${var.project_unique_id}-frontend"
  location = var.gcp_default_region
  template {
    spec {
      container_concurrency = 80
      containers {
        image = "gcr.io/cloudrun/hello"
        resources {
          limits = {
            "cpu"    = "1000m"
            "memory" = "256M"
          }
        }
      }
    }
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale" = "1000"
      }
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
  metadata {
    namespace = var.gcp_project_id
  }
}

resource "google_cloud_run_service_iam_policy" "frontend" {
  location = google_cloud_run_service.frontend.location
  project  = google_cloud_run_service.frontend.project
  service  = google_cloud_run_service.frontend.name

  policy_data = data.google_iam_policy.noauth.policy_data
}
