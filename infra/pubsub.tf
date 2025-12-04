# ---------------------------------------------------------
# Topic principal para notificaciones de imágenes nuevas
# ---------------------------------------------------------
resource "google_pubsub_topic" "image_events" {
  name = "${var.project_id}-image-events"
}


# ---------------------------------------------------------
# Suscripción tipo PUSH → envía mensajes a Cloud Run
# ---------------------------------------------------------
resource "google_pubsub_subscription" "image_events_sub" {
  name  = "${var.project_id}-image-events-sub"
  topic = google_pubsub_topic.image_events.name

  ack_deadline_seconds = 20
  message_retention_duration = "1200s" # 20 min
  retain_acked_messages      = false

  push_config {
    push_endpoint = google_cloud_run_service.image_processor.status[0].url

    oidc_token {
      service_account_email = google_service_account.pubsub_sa.email
    }
  }

  depends_on = [
    google_cloud_run_service.image_processor
  ]
}


# ---------------------------------------------------------
# Vinculación GCS → Pub/Sub (eventos OBJECT_FINALIZE)
# ---------------------------------------------------------
resource "google_storage_notification" "raw_object_finalize" {
  bucket         = google_storage_bucket.raw_bucket.name
  topic          = google_pubsub_topic.image_events.id
  payload_format = "JSON_API_V1"

  event_types = [
    "OBJECT_FINALIZE"
  ]

  depends_on = [
    google_pubsub_topic.image_events
  ]
}

# IAM para que Storage pueda publicar en el topic
resource "google_pubsub_topic_iam_member" "storage_publisher" {
  topic = google_pubsub_topic.image_events.name
  role  = "roles/pubsub.publisher"
  member = "serviceAccount:service-${var.project_number}@gs-project-accounts.iam.gserviceaccount.com"
}
