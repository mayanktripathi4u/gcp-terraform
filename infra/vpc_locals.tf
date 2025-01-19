locals {
  project_id = "my-gcp-project"
  region = "us-central1"

  apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "logging.googleapis.com",
    "secretmanager.googleapis.com",
  ]
}
