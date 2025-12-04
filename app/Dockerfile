# ---------------------------------------------------------
# Etapa 1: Imagen base ligera
# ---------------------------------------------------------
FROM python:3.11-slim AS base

ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Instalar dependencias del sistema necesarias para Pillow
RUN apt-get update && apt-get install -y --no-install-recommends \
    libjpeg62-turbo-dev \
    zlib1g-dev \
    libpng-dev \
    && rm -rf /var/lib/apt/lists/*

# Crear directorio de la app
WORKDIR /app

# Copiar dependencias
COPY requirements.txt .

# Instalar dependencias Python
RUN pip install --no-cache-dir -r requirements.txt

# Copiar aplicación
COPY processor.py .

# Puerto base de Cloud Run
ENV PORT=8080

# Comando de inicio (Gunicorn con Flask)
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "processor:app"]
