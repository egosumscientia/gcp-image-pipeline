resource "google_cloud_run_service" "image_processor" {
  name     = "${var.project_id}-image-processor"
  location = var.region

  template {
    spec {
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
resource "google_cloud_run_v2_service_iam_member" "invoker" {
  name     = google_cloud_run_v2_service.image_processor.name
  location = google_cloud_run_v2_service.image_processor.location
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

# ---------------------------------------------
# IAM: permisos mínimos para procesar imágenes
# ---------------------------------------------

# Cloud Run SA → lectura desde bucket raw
resource "google_storage_bucket_iam_member" "raw_reader" {
  bucket = var.raw_bucket_name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.cloudrun_sa.email}"
}

# Cloud Run SA → escritura en bucket processed
resource "google_storage_bucket_iam_member" "processed_writer" {
  bucket = var.processed_bucket_name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.cloudrun_sa.email}"
}
