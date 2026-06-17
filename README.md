# Draw.io Server (CloudStore Template)

Self-hosted [Draw.io / diagrams.net](https://www.drawio.com/) für kollaborative Diagramme — UML, Flowcharts, ER-Modelle, Netzwerk-Diagramme.

## Features

- Kein Login nötig — Studierende öffnen direkt die URL
- Läuft als offizieller `jgraph/drawio` Docker-Container
- Diagramme werden lokal im Browser gespeichert (LocalStorage) oder als Datei exportiert
- Apache 2.0 lizenziert, komplett kostenlos

## Parameter

| Parameter | Typ | Beschreibung |
|-----------|-----|-------------|
| `app_name` | string | Name der Instanz (3-20 Zeichen, lowercase) |
| `flavor_name` | selection | VM-Größe: `gp1.small` (Empfohlen) oder `gp1.medium` |

## Outputs

- `drawio_url` — Web-Oberfläche (Port 8080)
- `ssh_command` — SSH-Zugang zur VM
- `ssh_private_key` — Private Key (sensitive)

## Ports

- `22/tcp` — SSH
- `8080/tcp` — Draw.io Web UI
