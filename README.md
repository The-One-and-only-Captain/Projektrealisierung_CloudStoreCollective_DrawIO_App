# Draw.io Diagram Server

Self-hosted [Draw.io / diagrams.net](https://www.drawio.com/) als Docker-Container — kollaborative Diagramme (UML, Flowcharts, ER-Modelle, Netzwerk-Diagramme) ohne Login.

## Konzept

Ein Docker-Container, der die offizielle Draw.io-Web-App ausliefert. Kein User-Management, kein Login — jeder, der die URL kennt, kann Diagramme erstellen. Diagramme werden im **LocalStorage des Browsers** des jeweiligen Studierenden gespeichert (oder als Datei exportiert). Es gibt **keinen geteilten Server-State**.

**Deploy-Strategien:**

- **`one-instance`** — eine Draw.io-VM für den ganzen Kurs. Alle Studierenden teilen sich die URL, aber jeder hat seine eigenen Diagramme im Browser-LocalStorage.
- **`one-per-group`** — eine Draw.io-VM pro Projektgruppe. Sinnvoll für klare Trennung zwischen Gruppen, z.B. wenn jede Gruppe ihre eigene URL kommunizieren soll.

Es gibt kein `one-per-user` — das wäre Verschwendung, weil Draw.io zustandslos ist.

## Parameter

### Allgemein

| Parameter | Typ | Pflicht | Beschreibung |
|---|---|---|---|
| `app_name` | string | ja | Identifier (3-20 Kleinbuchstaben/Zahlen/`-`) |
| `student_groups` | groups (group-builder) | bei `one-per-group` | Projektgruppen — nur befüllen, wenn pro Gruppe eine eigene VM gewünscht ist |

### Ressourcen

| Parameter | Typ | Default | Beschreibung |
|---|---|---|---|
| `flavor_name` | selection | `gp1.small` | VM-Größe (Small reicht — Draw.io ist sehr genügsam) |

## Outputs

| Output | Sichtbar | Sensitive | Beschreibung |
|---|---|---|---|
| `instance_id` | nein | nein | VM-ID (intern) |
| `app_name` | ja | nein | Projektname |
| `drawio_url` | ja | nein | `http://<floating-ip>:8080` |
| `ssh_command` | ja | nein | SSH-Vorlage |
| `ssh_private_key` | nein | ja | SSH Private Key (für Admin-Zugang) |

## Setup-Ablauf (cloud-init)

1. Ubuntu 22.04 + Pakete (`curl`, `ca-certificates`, `ufw`)
2. UFW: Ports 22, 8080
3. Docker installieren (via offiziellem `get.docker.com`-Skript)
4. **Systemd-Service** `cloudstore-drawio.service`:
   - Pullt `jgraph/drawio:latest`
   - Startet Container mit Port-Mapping `8080:8080`
   - Restart-Policy `always`

## Zugriff

### Studierende

1. Browser öffnen: `drawio_url` (`http://<floating-ip>:8080`)
2. Sofort losarbeiten — kein Login
3. Diagramm speichern:
   - **Lokal im Browser:** Draw.io speichert in LocalStorage des aktuellen Browsers
   - **Als Datei exportieren:** File → Export → PNG, SVG, XML, PDF
   - **Lokal auf eigenem Computer:** File → Save → "Device" wählen

### Dozent (Admin)

```bash
# SSH-Zugang zur VM
ssh -i ./key.pem ubuntu@<floating-ip>

# Container-Status
sudo systemctl status cloudstore-drawio.service
sudo docker ps

# Container neu starten
sudo systemctl restart cloudstore-drawio.service

# Container-Logs anschauen
sudo docker logs drawio
```

## Ports

| Port | Zweck |
|---|---|
| 22 | SSH (Admin via Key) |
| 8080 | Draw.io Web UI (HTTP) |

HTTPS ist nicht konfiguriert. Für Produktiv-Setups Reverse-Proxy (nginx) vorschalten.

## Hinweise

- **Keine serverseitige Speicherung:** Diagramme leben nur im Browser des Studierenden oder als exportierte Dateien. Bei VM-Destroy gehen **keine** Daten verloren (es gibt keine).
- **Kollaboratives Editieren:** Draw.io selbst-gehostet unterstützt **kein Echtzeit-Co-Editing** wie die SaaS-Version. Für Gruppenarbeit: Eine Person bearbeitet, exportiert XML, teilt mit anderen.
- **Persistente Diagramme:** Studierende sollten regelmäßig File → Save (Device) oder Export, damit Diagramme nicht beim Browser-Cache-Leeren verloren gehen.
