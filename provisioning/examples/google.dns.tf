resource "google_dns_managed_zone" "main" {
  name     = var.project_unique_id
  dns_name = "google-cloud.${var.base_dnsdomain}."
  dnssec_config {
    state = "on"
  }
}

output "google_dns_main" {
  value = {
    dns_name     = google_dns_managed_zone.main.dns_name,
    name_servers = google_dns_managed_zone.main.name_servers,
  }
}
