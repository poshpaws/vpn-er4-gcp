terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = ">3.66.1"
    }
  }
}

variable "region" {}
variable "project" {}
  
provider "google" {
    project = var.project
    region = var.region
  # Configuration options
}
