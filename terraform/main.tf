# 1. Enable required Google Cloud APIs
resource "google_project_service" "apis" {
  project = var.gcp_project_id
  for_each = toset([
    "artifactregistry.googleapis.com",
    "container.googleapis.com",
    "cloudbuild.googleapis.com",
    "compute.googleapis.com", # Added for VPC Network
  ])
  service                    = each.key
  disable_on_destroy         = false
}

# 2. Create a dedicated VPC Network for the GKE cluster
resource "google_compute_network" "gke_network" {
  project                 = var.gcp_project_id
  name                    = "gke-vpc-network"
  auto_create_subnetworks = false # We will create our own subnetwork
  depends_on              = [google_project_service.apis]
}

# 3. Create a subnetwork within our VPC
resource "google_compute_subnetwork" "gke_subnetwork" {
  project       = var.gcp_project_id
  name          = "gke-vpc-subnetwork"
  ip_cidr_range = "10.10.0.0/24"
  region        = "asia-south1"
  network       = google_compute_network.gke_network.id
}

# 4. Create an Artifact Registry to store Docker images
resource "google_artifact_registry_repository" "my_repo" {
  project       = var.gcp_project_id
  location      = "asia-south1"
  repository_id = "my-python-app-repo"
  description   = "Docker repository for my python app"
  format        = "DOCKER"
  depends_on    = [google_project_service.apis]
}

# 5. Create a GKE Autopilot cluster with an explicit IP allocation policy
resource "google_container_cluster" "primary" {
  project          = var.gcp_project_id
  name             = "my-gke-autopilot-cluster"
  location         = "asia-south1"
  enable_autopilot = true
  
  network    = google_compute_network.gke_network.id
  subnetwork = google_compute_subnetwork.gke_subnetwork.id

  # This block explicitly enables VPC-native networking, overriding the bad default.
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "10.1.0.0/16"
    services_ipv4_cidr_block = "10.2.0.0/16"
  }

  depends_on = [
    google_project_service.apis,
    google_compute_subnetwork.gke_subnetwork
  ]
}
