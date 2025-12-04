# GCP Serverless Image Processing Pipeline

Pipeline serverless para procesamiento automático de imágenes mediante Cloud Storage, Pub/Sub y Cloud Run. El sistema genera thumbnails y versiones procesadas al detectar nuevos objetos en un bucket de entrada.

---

## Arquitectura

1. Un archivo es cargado en **Cloud Storage (bucket raw)**.
2. El evento `OBJECT_FINALIZE` genera una notificación a **Pub/Sub**.
3. Un servicio en **Cloud Run** recibe el mensaje y procesa la imagen.
4. La versión procesada es almacenada en **Cloud Storage (bucket processed)**.
5. Logs y métricas se registran en **Cloud Logging**.

Diagrama conceptual:

```
GCS (raw) → Pub/Sub → Cloud Run → GCS (processed)
```

---

## Servicios utilizados

* Cloud Storage
* Pub/Sub
* Cloud Run
* Artifact Registry
* IAM
* Cloud Logging

---

## Estructura del repositorio

```
gcp-image-pipeline/
│
├── infra/
│   ├── main.tf
│   ├── storage.tf
│   ├── pubsub.tf
│   ├── cloudrun.tf
│   ├── variables.tf
│   └── outputs.tf
│
├── app/
│   ├── Dockerfile
│   ├── requirements.txt
│   └── processor.py
│
└── docs/
    └── README.md
```

---

## Flujo de despliegue

1. Construcción y push de imagen a Artifact Registry:

   ```bash
   gcloud builds submit --tag us-central1-docker.pkg.dev/PROJECT/REPO/image-processor:latest
   ```

2. Aplicación de la infraestructura con Terraform:

   ```bash
   cd infra
   terraform init
   terraform apply
   ```

3. Cloud Run se despliega con la imagen generada.

4. Cloud Storage y Pub/Sub quedan conectados automáticamente al servicio.

---

## Procesamiento

El contenedor ejecuta `processor.py`.
Acciones soportadas:

* Generación de thumbnails
* Redimensionamiento
* Conversión JPEG/PNG → JPEG

Bibliotecas utilizadas:

* Pillow
* Google Cloud Storage Client

---

## Requisitos

* Terraform >= 1.6
* Google Cloud SDK
* Proyecto GCP con billing habilitado
* Docker o Podman para construcción de imágenes

---

## Pruebas

1. Subir una imagen JPEG/PNG al bucket **raw**.
2. Verificar la llegada del mensaje en el tópico Pub/Sub.
3. Confirmar que Cloud Run procesa la imagen (Cloud Logging).
4. Validar el archivo final en el bucket **processed**.

---

## Limpieza

```bash
cd infra
terraform destroy
```

---

## Licencia

Este proyecto se distribuye sin garantías. Uso interno y educativo.



************************
terraform init
terraform validate
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars" -auto-approve
terraform destroy -auto-approve

************************

1. Flujo real:

Tienes imágenes locales en Windows:
C:\Users\TU_USUARIO\Downloads\foto1.jpg, foto2.png, etc.

Las copias al bucket RAW:
gs://imaging-pipeline-prod-raw/uploads/foto1.jpg

Cuando termina la subida, Cloud Storage genera el evento OBJECT_FINALIZE.

Pub/Sub envía el mensaje a Cloud Run.

Cloud Run descarga la imagen, la procesa y la sube a:
gs://imaging-pipeline-prod-processed/...

Nada pasa mientras los archivos estén solo en Downloads.