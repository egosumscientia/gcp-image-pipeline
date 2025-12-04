terraform {
  required_version = ">= 1.6.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# ---------------------------------------------------------
# Enable APIs necesarias para Storage, Pub/Sub y Cloud Run
# ---------------------------------------------------------
resource "google_project_service" "services" {
  for_each = toset([
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
    "pubsub.googleapis.com",
    "storage.googleapis.com",
    "cloudbuild.googleapis.com"
  ])

  project = var.project_id
  service = each.key

  disable_on_destroy = false
}

# ---------------------------------------------------------
# Archivos locales restantes se cargan automáticamente
# (cloudrun.tf, pubsub.tf, storage.tf, variables.tf, outputs.tf)
# ---------------------------------------------------------
# No se necesita incluir nada más aquí.

