resource "aws_ses_domain_identity" "main" {
  domain = var.base_dnsdomain
}

resource "aws_ses_domain_dkim" "main" {
  domain = aws_ses_domain_identity.main.domain
}

resource "google_dns_record_set" "amazonses" {
  name = format(
    "_amazonses.%s.",
    var.base_dnsdomain
  )

  type         = "TXT"
  ttl          = 3600
  managed_zone = google_dns_managed_zone.main.name
  rrdatas = [
    aws_ses_domain_identity.main.verification_token
  ]
}

resource "google_dns_record_set" "amazonses_dkim" {
  count = 3

  name = format(
    "%s._domainkey.%s.",
    element(aws_ses_domain_dkim.main.dkim_tokens, count.index),
    var.base_dnsdomain
  )

  type         = "CNAME"
  ttl          = 3600
  managed_zone = google_dns_managed_zone.main.name
  rrdatas = [
    "${element(aws_ses_domain_dkim.main.dkim_tokens, count.index)}.dkim.amazonses.com."
  ]
}
