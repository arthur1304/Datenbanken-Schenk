# Docker Setup & Datengenerierung

## Voraussetzungen

- Docker Desktop installiert und gestartet
- Docker Compose verfügbar

## Projektstruktur

```
Datenbanken-Schenk/
├── docker-compose.yml
├── Dockerfile
├── db/
│   └── init.sql
└── data_generation/
    └── load_fake_data.py
```

## Docker-Container starten

### 1. Container erstellen und starten

```bash
docker-compose up -d --build
```

**Was passiert:**
- PostgreSQL-Datenbank wird gestartet (Container: `projekt_db`)
- Python-Anwendung wird gestartet (Container: `projekt_app`)
- Die Datenbank wird mit `init.sql` initialisiert
- Beide Container laufen im Hintergrund (`-d` = detached mode)

### 2. Status prüfen

```bash
docker-compose ps
```

Du solltest beide Container sehen:
- `projekt_db` (Status: Up, healthy)
- `projekt_app` (Status: Up)

### 3. Logs ansehen (optional)

```bash
# Alle Logs
docker-compose logs

# Nur DB-Logs
docker-compose logs db

# Nur App-Logs
docker-compose logs app

# Logs live verfolgen
docker-compose logs -f
```

## Daten generieren

### Small Dataset generieren

```bash
docker-compose exec app python load_fake_data.py small
```

**Generiert:**
- 5 Rollen
- 5 Standorte
- 50 Kunden
- 50 Mitarbeiter
- 30 Projekte
- ~3.000 Assignments
- ~5.000 Work Schedule Einträge

**Dauer:** ca. 10-30 Sekunden

### Large Dataset generieren

```bash
docker-compose exec app python load_fake_data.py large
```

**Generiert:**
- 5 Rollen
- 10 Standorte
- 500 Kunden
- 200 Mitarbeiter
- 200 Projekte
- ~100.000 Assignments
- ~73.000 Work Schedule Einträge

**Dauer:** ca. 2-5 Minuten

## Datenbank-Zugriff

### Mit einem SQL-Client verbinden

- **Host:** `localhost`
- **Port:** `5432`
- **Database:** `projektdb`
- **User:** `projektuser`
- **Password:** `projektpass`

### Mit psql (im Container)

```bash
docker-compose exec db psql -U projektuser -d projektdb
```

Beispiel-Queries:
```sql
-- Anzahl Mitarbeiter
SELECT COUNT(*) FROM employees;

-- Anzahl Projekte
SELECT COUNT(*) FROM projects;

-- Alle Tabellen anzeigen
\dt
```

## Container stoppen und neustarten

### Container stoppen

```bash
docker-compose down
```

**Wichtig:** Die Daten bleiben erhalten (gespeichert im Volume `db_data`)

### Container stoppen und Daten löschen

```bash
docker-compose down -v
```

**Achtung:** Das `-v` Flag löscht alle Volumes und damit auch die Datenbank-Daten!

### Container neustarten

```bash
docker-compose up -d
```

Die Daten sind noch vorhanden, da das Volume nicht gelöscht wurde.

## Troubleshooting

### Container läuft nicht

```bash
# Status prüfen
docker-compose ps

# Logs ansehen
docker-compose logs app
docker-compose logs db
```

### Datenbank-Verbindung schlägt fehl

Warte, bis die Datenbank "healthy" ist:
```bash
docker-compose ps
```

Oder prüfe die DB-Logs:
```bash
docker-compose logs db
```

### Daten neu generieren

1. Datenbank zurücksetzen:
```bash
docker-compose down -v
docker-compose up -d
```

2. Daten neu generieren:
```bash
docker-compose exec app python load_fake_data.py small
```

### Python-Pakete fehlen

Rebuild des Containers:
```bash
docker-compose down
docker-compose build --no-cache app
docker-compose up -d
```

## Nützliche Befehle

```bash
# Alle Container stoppen
docker-compose stop

# Alle Container starten
docker-compose start

# Container neu bauen (nach Code-Änderungen)
docker-compose up -d --build

# In den App-Container einsteigen (Shell)
docker-compose exec app bash

# Python interaktiv im Container
docker-compose exec app python

# Alle Docker-Ressourcen aufräumen
docker-compose down -v
docker system prune -a
```