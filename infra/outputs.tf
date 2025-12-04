output "raw_bucket_name" {
  description = "Bucket de entrada para imágenes."
  value       = google_storage_bucket.raw_bucket.name
}

output "processed_bucket_name" {
  description = "Bucket de salida con imágenes procesadas."
  value       = google_storage_bucket.processed_bucket.name
}

output "pubsub_topic" {
  description = "Tópico Pub/Sub que recibe eventos de GCS."
  value       = google_pubsub_topic.image_events.name
}

output "pubsub_subscription" {
  description = "Suscripción push que invoca Cloud Run."
  value       = google_pubsub_subscription.image_events_sub.name
}

output "cloud_run_url" {
  description = "URL del servicio Cloud Run encargado del procesamiento."
  value       = google_cloud_run_v2_service.image_processor.uri
}

output "cloud_run_service_account" {
  description = "Service Account usada por Cloud Run."
  value       = google_service_account.cloudrun_sa.email
}

output "pubsub_invoker_service_account" {
  description = "Service Account usada por Pub/Sub para invocar Cloud Run."
  value       = google_service_account.pubsub_sa.email
}
