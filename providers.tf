terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">3.66.1"
    }
  }
}

locals {
  tf_state_bucket = format("%s-tf_state_bucket",lower(data.google_project.trident45.name))
}

provider "google" {
    project = "trident45"
    region = "europe-west2"
  # Configuration options
}
