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

provider "google" {
  # credentials = {
  #   json_key = var.google_credentials
  # }
  project     = "ninth-victor-389223"
  region      = "us-central1"
}

provider "google-beta" {
  # credentials = {
  #   json_key = var.google_credentials
  # }
  project     = "ninth-victor-389223"
  region      = "us-central1"
}

# tf-sa-375@ninth-victor-389223.iam.gserviceaccount.com

# provider "google" {
#   project     = "ninth-victor-389223"
#   credentials = file(var.gcp_auth_file)
# }

# provider "google-beta" {
#   project     = "ninth-victor-389223"
#   credentials = file(var.gcp_auth_file)
# }

# resource "random_string" "backend_api_key" {
#   length  = 26
#   special = false
# }

resource "google_project" "main" {
  name       = "My Project"
  project_id = "ninth-victor-389223"
}

resource "google_storage_bucket" "static-site" {
  name          = "image-store.com"
  location      = "EU"
  force_destroy = true

  uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
  cors {
    origin          = ["http://image-store.com"]
    method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
}