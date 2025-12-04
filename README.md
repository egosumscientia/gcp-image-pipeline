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
