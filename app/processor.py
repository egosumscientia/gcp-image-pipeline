import base64
import json
import logging
import os
from io import BytesIO
from flask import Flask, request

from google.cloud import storage
from PIL import Image

app = Flask(__name__)
storage_client = storage.Client()

OUTPUT_BUCKET = os.environ.get("OUTPUT_BUCKET")

logging.basicConfig(level=logging.INFO)


def download_from_gcs(bucket_name, object_name):
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(object_name)
    return blob.download_as_bytes()


def upload_to_gcs(bucket_name, object_name, content_bytes, content_type):
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(object_name)
    blob.upload_from_string(content_bytes, content_type=content_type)


def generate_thumbnail(image_bytes, size=(300, 300)):
    img = Image.open(BytesIO(image_bytes))
    img.thumbnail(size)
    buffer = BytesIO()
    img.save(buffer, format="JPEG", quality=85)
    return buffer.getvalue()


@app.post("/")
def index():
    envelope = request.get_json(silent=True)

    if not envelope:
        logging.error("No Pub/Sub message received.")
        return ("", 400)

    if "message" not in envelope:
        logging.error("Pub/Sub envelope without message field.")
        return ("", 400)

    pubsub_message = envelope["message"]
    if "data" not in pubsub_message:
        logging.error("Pub/Sub message without data.")
        return ("", 400)

    # Decodificar payload
    payload = json.loads(base64.b64decode(pubsub_message["data"]).decode("utf-8"))

    bucket_name = payload["bucket"]
    object_name = payload["name"]

    logging.info(f"Procesando objeto {object_name} desde bucket {bucket_name}")

    # Descargar imagen original
    raw_bytes = download_from_gcs(bucket_name, object_name)

    # Generar thumbnail
    thumbnail_bytes = generate_thumbnail(raw_bytes)

    # Nombre final en el bucket processed
    output_name = f"thumb_{object_name}.jpg"

    upload_to_gcs(
        OUTPUT_BUCKET,
        output_name,
        thumbnail_bytes,
        content_type="image/jpeg"
    )

    logging.info(f"Thumbnail generado y guardado como {output_name}")

    return ("", 200)


if __name__ == "__main__":
    app.run(debug=False, host="0.0.0.0", port=8080)
