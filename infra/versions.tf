# Required versions for terrafform and google.
terraform {
  backend "gcs" {
    bucket = "liatrio-tf-state"
    prefix = "terraform/state"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0.0, < 6.0.0"
    }
  }
  required_version = ">=1.3"
}