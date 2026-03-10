terraform {
  # https://developer.hashicorp.com/terraform/install
  # See https://developer.hashicorp.com/terraform/language/expressions/version-constraints#version-constraint-syntax
  #  = (or no operator): Allows only one exact version number. Cannot be combined with other conditions.
  #  !=: Excludes an exact version number.
  #  >, >=, <, <=: Comparisons against a specified version, allowing versions for which the comparison is true. "Greater-than" requests newer versions, and "less-than" requests older versions.
  #  ~>: Allows only the rightmost version component to increment. For example, to allow new patch releases within a specific minor release, use the full version number: ~> 1.0.4 will allow installation of 1.0.5 and 1.0.10 but not 1.1.0. This is usually called the pessimistic constraint operator.
  required_version = "~> 1.13.0"

  required_providers {
    # https://registry.terraform.io/providers/hashicorp/aws/latest
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.11.0"
    }
    # https://registry.terraform.io/providers/hashicorp/azurerm/latest
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.42.0"
    }
    # https://registry.terraform.io/providers/hashicorp/google/latest
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0.0"
    }
    # https://registry.terraform.io/providers/hashicorp/google-beta/latest
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 7.0.0"
    }
  }
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_default_region
}

provider "azurerm" {
  features {}
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_default_region
  zone    = "${var.gcp_default_region}-a"
}

provider "google-beta" {
  project = var.gcp_project_id
  region  = var.gcp_default_region
  zone    = "${var.gcp_default_region}-a"
}
