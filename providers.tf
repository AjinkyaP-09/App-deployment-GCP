terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  project = "application-deployment-471707" # <-- CHANGE THIS
  region  = "asia-south1"         # <-- MODIFIED
}
