# ---------------------------------------------------------
# Bucket RAW (entrada)
# ---------------------------------------------------------
resource "google_storage_bucket" "raw_bucket" {
  name                        = var.raw_bucket_name
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy               = false

  versioning {
    enabled = false
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 30
    }
  }
}

# ---------------------------------------------------------
# Bucket PROCESSED (salida)
# ---------------------------------------------------------
resource "google_storage_bucket" "processed_bucket" {
  name                        = var.processed_bucket_name
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy               = false

  versioning {
    enabled = false
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      age = 30
    }
  }
}

# ---------------------------------------------------------
# IAM para permitir que Cloud Run escriba resultados
# (El binding principal se hace en cloudrun.tf, pero aquí
# mantenemos explícitas las dependencias si se requieren)
# ---------------------------------------------------------
resource "google_storage_bucket_iam_member" "processed_writer" {
  bucket = google_storage_bucket.processed_bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.cloudrun_sa.email}"

  depends_on = [
    google_storage_bucket.processed_bucket
  ]
}

resource "google_storage_bucket_iam_member" "raw_reader" {
  bucket = google_storage_bucket.raw_bucket.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.cloudrun_sa.email}"

  depends_on = [
    google_storage_bucket.raw_bucket
  ]
}
