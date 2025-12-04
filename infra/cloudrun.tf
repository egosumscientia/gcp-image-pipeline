resource "google_cloud_run_service" "image_processor" {
  name     = "${var.project_id}-image-processor"
  location = var.region

  template {
    spec {
      service_account_name = google_service_account.cloudrun_sa.email

      containers {
        image = var.image_url

        env {
          name  = "OUTPUT_BUCKET"
          value = var.processed_bucket_name
        }

        resources {
          limits = {
            cpu    = "1"
            memory = "512Mi"
          }
        }
      }
    }
  }

  traffic {
    percent = 100
    latest_revision = true
  }
}

# ---------------------------------------------
# IAM: Permisos mínimos para Cloud Run
# ---------------------------------------------

# Invocación del service por Pub/Sub (push)
resource "google_cloud_run_service_iam_member" "invoker" {
  location = google_cloud_run_service.image_processor.location
  service  = google_cloud_run_service.image_processor.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.pubsub_sa.email}"
}

# ---------------------------------------------
# Service Accounts
# ---------------------------------------------

# SA usada por Cloud Run
resource "google_service_account" "cloudrun_sa" {
  account_id   = "cloudrun-imageproc-sa"
  display_name = "Cloud Run Image Processor SA"
}

# SA usada por Pub/Sub para ejecutar el servicio
resource "google_service_account" "pubsub_sa" {
  account_id   = "pubsub-cloudrun-invoker-sa"
  display_name = "Pub/Sub Invoker for Cloud Run"
}
