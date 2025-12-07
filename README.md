# Projekt-Datenbank – PM/Controlling System

Dieses Repository enthält:
- Ein reproduzierbares PostgreSQL-Datenbanksystem (Docker + SQL Schema)
- Python-Fake-Daten-Generator (Small + Large Dataset)
- SQL-Validierungsskripte
- Dokumentation des Datenmodells

## Voraussetzungen
- Docker Desktop
- Python 3.10+
- VS Code oder beliebiger Editor

## Datenbank starten
```bash
docker compose up -d

##Die Datenbank läuft danach unter:

Host: localhost

Port: 5432

DB: projektdb

User: projektuser

Password: projektpass