resource "google_dns_record_set" "frontend-verification" {
  name         = "frontend.${var.base_dnsdomain}."
  type         = "TXT"
  ttl          = 3600
  managed_zone = google_dns_managed_zone.main.name
  rrdatas      = ["google-site-verification=71iqF_6vUGNJSt64AKUIkNZhnQAIhjx6gDRaVoYDsIs"]
}

resource "google_dns_record_set" "frontend-a" {
  name         = "frontend.${var.base_dnsdomain}."
  type         = "A"
  ttl          = 3600
  managed_zone = google_dns_managed_zone.main.name
  rrdatas = [
    for rr in google_cloud_run_domain_mapping.frontend.status[0].resource_records :
    rr.rrdata if rr.type == "A"
  ]
}

resource "google_dns_record_set" "frontend-aaaa" {
  name         = "frontend.${var.base_dnsdomain}."
  type         = "AAAA"
  ttl          = 3600
  managed_zone = google_dns_managed_zone.main.name
  rrdatas = [
    for rr in google_cloud_run_domain_mapping.frontend.status[0].resource_records :
    rr.rrdata if rr.type == "AAAA"
  ]
}
