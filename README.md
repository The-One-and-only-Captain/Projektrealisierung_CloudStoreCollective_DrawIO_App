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

1. Ubuntu 22.04 + Pakete (`curl`, `ca-certificates`, `ufw`, `nginx`, `openssl`)
2. UFW: Ports 22, 80, 443
3. Docker installieren (via offiziellem `get.docker.com`-Skript)
4. **Systemd-Service** `cloudstore-drawio.service`:
   - Pullt `jgraph/drawio:latest`
   - Startet Container mit Port-Binding **nur lokal** (`127.0.0.1:8080`)
   - Restart-Policy `always`
5. Self-Signed SSL-Zertifikat (`openssl req -x509`, 365 Tage gültig)
6. Nginx als Reverse-Proxy: 80 → 301 Redirect auf 443, 443 → Docker-Container auf 127.0.0.1:8080

## Zugriff

### Studierende

1. Browser öffnen: `drawio_url` (`https://<floating-ip>`)
2. **Self-Signed Cert akzeptieren** (Browser-Warnung wegklicken — Cert wird nicht von einer offiziellen CA signiert)
3. Sofort losarbeiten — kein Login
4. Diagramm speichern:
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
| 80 | HTTP → 301 Redirect auf HTTPS |
| 443 | HTTPS (Draw.io via Nginx + Self-Signed Cert) |

Der Draw.io-Container selbst bindet **nur auf 127.0.0.1:8080** — direkt von außen nicht erreichbar, nur über den Nginx-Proxy.

## Hinweise

- **Self-Signed Zertifikat:** Browser warnt beim ersten Aufruf ("Verbindung nicht sicher"). Cert ist 365 Tage gültig. Für Produktiv-Setups Let's Encrypt einrichten (DNS-Hostname nötig).
- **Keine serverseitige Speicherung:** Diagramme leben nur im Browser des Studierenden oder als exportierte Dateien. Bei VM-Destroy gehen **keine** Daten verloren (es gibt keine).
- **Kollaboratives Editieren:** Draw.io selbst-gehostet unterstützt **kein Echtzeit-Co-Editing** wie die SaaS-Version. Für Gruppenarbeit: Eine Person bearbeitet, exportiert XML, teilt mit anderen.
- **Persistente Diagramme:** Studierende sollten regelmäßig File → Save (Device) oder Export, damit Diagramme nicht beim Browser-Cache-Leeren verloren gehen.
