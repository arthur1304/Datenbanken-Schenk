# Basis-Image mit Python 3
FROM python:3.11-slim

# PostgreSQL-Client-Bibliotheken installieren (für psycopg2)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libpq-dev \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Python-Pakete installieren
RUN pip install --no-cache-dir \
    psycopg2-binary==2.9.9 \
    faker==22.6.0

# Arbeitsverzeichnis erstellen (wird durch Volume gemountet)
WORKDIR /app

# Standard-Command - Container am Laufen halten
CMD ["tail", "-f", "/dev/null"]