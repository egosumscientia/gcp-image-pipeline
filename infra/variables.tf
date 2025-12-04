# ---------------------------------------------------------
# Proyecto y región
# ---------------------------------------------------------
variable "project_id" {
  description = "ID del proyecto GCP."
  type        = string
}

variable "project_number" {
  description = "Número del proyecto GCP."
  type        = string
}

variable "region" {
  description = "Región principal para servicios (Cloud Run, Storage, etc.)."
  type        = string
  default     = "us-central1"
}

# ---------------------------------------------------------
# Buckets
# ---------------------------------------------------------
variable "raw_bucket_name" {
  description = "Nombre del bucket donde se suben las imágenes originales."
  type        = string
}

variable "processed_bucket_name" {
  description = "Nombre del bucket donde se almacenan las imágenes procesadas."
  type        = string
}

# ---------------------------------------------------------
# Imagen de Cloud Run
# ---------------------------------------------------------
variable "image_url" {
  description = "URL completa de la imagen en Artifact Registry para Cloud Run."
  type        = string
}

