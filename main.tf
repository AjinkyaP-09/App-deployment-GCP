# ... (resource "google_project_service" "apis" remains the same) ...

# 2. Create an Artifact Registry to store Docker images
resource "google_artifact_registry_repository" "my_repo" {
  project       = "application-deployment-471707" # <-- CHANGE THIS
  location      = "asia-south1"         # <-- MODIFIED
  repository_id = "my-python-app-repo"
  description   = "Docker repository for my python app"
  format        = "DOCKER"
  depends_on    = [google_project_service.apis]
}

# 3. Create a GKE Autopilot cluster
resource "google_container_cluster" "primary" {
  project          = "application-deployment-471707" # <-- CHANGE THIS
  name             = "my-gke-autopilot-cluster"
  location         = "asia-south1"         # <-- MODIFIED
  enable_autopilot = true
  depends_on       = [google_project_service.apis]
}
