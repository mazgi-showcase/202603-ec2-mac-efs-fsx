# See https://www.terraform.io/language/settings/backends/gcs
terraform {
  backend "gcs" {
    prefix = "default/terraform"
  }
}
