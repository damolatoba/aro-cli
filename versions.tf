terraform {
  backend "gcs" {
    bucket = "my-gcp-state"
    prefix = "terraform/state/test"
  }
  required_providers {
    google = {
      version = "~> 4.65.0"
    }
    google-beta = {
      version = "~> 4.65.0"
    }
  }
}
