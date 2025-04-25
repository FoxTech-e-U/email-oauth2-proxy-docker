# Email OAuth 2.0 Proxy Docker

Dieses Repository enthält Docker-Konfigurationen für [Email OAuth 2.0 Proxy](https://github.com/simonrob/email-oauth2-proxy), ein Tool, das OAuth 2.0-Unterstützung zu E-Mail-Clients hinzufügt, die diese Authentifizierungsmethode nicht nativ unterstützen.

Entwickelt von [FoxTech e.U.](https://foxtech.at)

## Features

- Automatisierte Docker-Builds bei neuen Releases
- Einfache Konfiguration über Stack-Umgebungsvariablen (Portainer-kompatibel)
- Vorkonfigurierte Ports für IMAP, POP3 und SMTP
- Persistente Konfiguration und Token-Speicherung
- Headless-Modus mit lokalem Webserver für Authentifizierung

## Schnellstart

### Mit Docker Compose

1. Klone dieses Repository oder lade die Dateien herunter
2. Passe die `stack.env` Datei an (insbesondere CLIENT_ID, CLIENT_SECRET und EMAIL_ADDRESS)
3. Starte den Container:

```bash
docker-compose --env-file stack.env up -d
```

### Mit Portainer

1. Erstelle einen neuen Stack in Portainer
2. Lade die `docker-compose.yml` Datei hoch
3. Füge den Inhalt der `stack.env` Datei in den Environment-Bereich ein
4. Passe die Variablen an (insbesondere CLIENT_ID, CLIENT_SECRET und EMAIL_ADDRESS)
5. Starte den Stack

## Konfiguration

Die Konfiguration erfolgt über Umgebungsvariablen in der `stack.env` Datei:

| Variable | Beschreibung | Standard |
|----------|-------------|---------|
| `EMAIL_PROVIDER` | E-Mail-Anbieter (z.B. office365, gmail) | office365 |
| `CLIENT_ID` | OAuth 2.0 Client ID | (erforderlich) |
| `CLIENT_SECRET` | OAuth 2.0 Client Secret | (erforderlich) |
| `EMAIL_ADDRESS` | E-Mail-Adresse | (erforderlich) |
| `REDIRECT_URI` | OAuth 2.0 Redirect URI | http://localhost:12345/ |
| `DEBUG_MODE` | Debug-Modus aktivieren | false |
| `IMAP_PORT` | Lokaler IMAP-Port | 1143 |
| `IMAPS_PORT` | Lokaler IMAPS-Port | 1993 |
| `POP3_PORT` | Lokaler POP3-Port | 1110 |
| `POP3S_PORT` | Lokaler POP3S-Port | 1995 |
| `SMTP_PORT` | Lokaler SMTP-Port | 1025 |
| `SMTPS_PORT` | Lokaler SMTPS-Port | 1587 |
| `NETWORK_MODE` | Docker-Netzwerkmodus | bridge |

## OAuth 2.0 Client Credentials

Um den Proxy nutzen zu können, benötigen Sie OAuth 2.0 Client Credentials für Ihren E-Mail-Provider:

### Office 365
Registrieren Sie eine neue [Microsoft Identity-Anwendung](https://learn.microsoft.com/entra/identity-platform/quickstart-register-app)

### Gmail / Google Workspace
Registrieren Sie eine [Google API Desktop-App](https://developers.google.com/identity/protocols/oauth2/native-app)

Weitere Informationen finden Sie in der [offiziellen Dokumentation](https://github.com/simonrob/email-oauth2-proxy#oauth-20-client-credentials).

## Authentifizierung

Nach dem Start des Containers muss das E-Mail-Konto authentifiziert werden:

1. Überprüfe die Container-Logs:
```bash
docker logs email-oauth2-proxy
```

2. Suche nach einer URL, die mit "Please visit the following URL to authorise access" beginnt
3. Öffne diese URL in deinem Browser und folge den Anweisungen
4. Nach erfolgreicher Authentifizierung werden die Token in der Konfigurationsdatei gespeichert

## E-Mail-Client konfigurieren

Konfiguriere deinen E-Mail-Client mit den folgenden Einstellungen:

- **IMAP-Server**: IP-Adresse des Docker-Hosts (z.B. `127.0.0.1` für lokale Installationen)
- **IMAP-Port**: 1143 (unverschlüsselt) oder 1993 (SSL/TLS)
- **POP3-Server**: IP-Adresse des Docker-Hosts
- **POP3-Port**: 1110 (unverschlüsselt) oder 1995 (SSL/TLS)
- **SMTP-Server**: IP-Adresse des Docker-Hosts
- **SMTP-Port**: 1025 (unverschlüsselt) oder 1587 (SSL/TLS)
- **Benutzername**: Deine vollständige E-Mail-Adresse
- **Passwort**: Kann ein beliebiger Wert sein, da die OAuth-Authentifizierung separat erfolgt

## Problembehandlung

### Authentifizierungsprobleme

Wenn die Web-Authentifizierung fehlschlägt, versuche:

1. Den Container mit dem Host-Netzwerkmodus zu starten (setze `NETWORK_MODE=host` in der `stack.env`-Datei)
2. Die `REDIRECT_URI` in der `stack.env`-Datei zu überprüfen
3. Aktiviere den Debug-Modus mit `DEBUG_MODE=true`

### Verbindungsprobleme

Stelle sicher, dass:
- Die Ports im Docker Compose richtig konfiguriert sind
- Die Container-IP-Adresse von deinem E-Mail-Client aus erreichbar ist
- Die Firewall-Einstellungen die entsprechenden Ports zulassen

## Erweiterte Konfiguration

Für fortgeschrittene Konfigurationen (mehrere Konten, benutzerdefinierte Server, etc.) kann eine manuelle Konfigurationsdatei verwendet werden. Erstelle eine `emailproxy.config` Datei im `config`-Verzeichnis nach dem [offiziellen Beispiel](https://github.com/simonrob/email-oauth2-proxy/blob/main/emailproxy.config).

## Automatische Updates

Das Docker-Image wird automatisch bei neuen Releases des originalen Email OAuth 2.0 Proxy-Projekts aktualisiert. Um immer die neueste Version zu verwenden, führe regelmäßig:

```bash
docker-compose --env-file stack.env pull
docker-compose --env-file stack.env up -d
```

## Lizenz

Dieses Projekt basiert auf [Email OAuth 2.0 Proxy](https://github.com/simonrob/email-oauth2-proxy) und steht unter der [Apache 2.0 Lizenz](https://github.com/simonrob/email-oauth2-proxy/blob/main/LICENSE).

Entwickelt von [FoxTech e.U.](https://foxtech.at)
