terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
    }
  }
}

provider "google" {
  project = "voltes-446205"
  region  = "us-central1"
}

resource "google_container_cluster" "voltes_cluster" {
  name                     = "voltes-cluster"
  location                 = "us-central1-a"
  remove_default_node_pool = true
  initial_node_count       = 1  # Corrected to set initial node count
  min_master_version       = "1.31.4-gke.1072000"

  lifecycle {
    prevent_destroy = false
  }
}

resource "google_container_node_pool" "default_pool" {
  cluster    = google_container_cluster.voltes_cluster.name
  location   = google_container_cluster.voltes_cluster.location
  node_count = 2

  node_config {
    machine_type = "e2-micro"
    tags         = ["gke-voltes-cluster"]
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}

resource "google_storage_bucket" "image_bucket" {
  name     = "voltes-image-bucket"
  location = "US"
  storage_class = "STANDARD"

  uniform_bucket_level_access = true
}

output "kubeconfig" {
  value = google_container_cluster.voltes_cluster.endpoint
}
