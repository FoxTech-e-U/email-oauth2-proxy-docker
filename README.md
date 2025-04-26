# Email OAuth 2.0 Proxy Docker

Dieses Repository enthält Docker-Konfigurationen für [Email OAuth 2.0 Proxy](https://github.com/simonrob/email-oauth2-proxy), ein Tool, das OAuth 2.0-Unterstützung zu E-Mail-Clients hinzufügt, die diese Authentifizierungsmethode nicht nativ unterstützen.

Entwickelt von [FoxTech e.U.](https://foxtech.at)

## Features

- Automatisierte Docker-Builds bei neuen Releases
- Einfache Konfiguration über Stack-Umgebungsvariablen (Portainer-kompatibel)
- Unterstützung für tenant-spezifische Office 365-Konfigurationen
- Unterstützung für Shared Mailboxes
- Persistente Konfiguration und Token-Speicherung

## Schnellstart

### Mit Docker Compose

1. Klone dieses Repository oder lade die Dateien herunter
2. Passe die `stack.env` Datei an (insbesondere CLIENT_ID, CLIENT_SECRET und EMAIL_ADDRESS)
3. Stelle sicher, dass Port 12345 für die OAuth-Authentifizierung freigegeben ist
4. Starte den Container:

```bash
docker-compose up -d
```

### Mit Portainer

1. Erstelle einen neuen Stack in Portainer
2. Lade die `docker-compose.yml` Datei hoch
3. Füge den Inhalt der `stack.env` Datei in den Environment-Bereich ein
4. Passe die Variablen an (insbesondere CLIENT_ID, CLIENT_SECRET und EMAIL_ADDRESS)
5. Starte den Stack

## OAuth 2.0 Client Credentials einrichten

Um den Proxy nutzen zu können, benötigen Sie OAuth 2.0 Client Credentials für Ihren E-Mail-Provider:

### Office 365 App-Registrierung erstellen:

1. Gehen Sie zu [portal.azure.com](https://portal.azure.com)
2. Navigieren Sie zu "App-Registrierungen" → "Neue Registrierung"
3. Geben Sie einen Namen ein und wählen Sie den richtigen Kontotyp 
   - Für eigene Tenants: "Nur Konten in diesem Organisationsverzeichnis"
   - Für gemeinsame Tenants: "Konten in einem Organisationsverzeichnis"
4. Setzen Sie als Umleitungs-URI: `http://localhost:12345/`
5. Unter "Zertifikate & Geheimnisse" erstellen Sie einen neuen Client-Secret
6. Unter "API-Berechtigungen" fügen Sie hinzu:
   - Microsoft Graph → Delegierte Berechtigungen
   - IMAP.AccessAsUser.All
   - POP.AccessAsUser.All
   - SMTP.Send
   - offline_access

Notieren Sie sich die Client-ID und den Client-Secret für die `stack.env`-Datei.

## Erstmalige Authentifizierung

**Wichtig:** Für die erste Authentifizierung muss der OAuth-Callback-Port (12345) von Ihrem Browser aus erreichbar sein.

### Methode 1: Direkte Authentifizierung mit curl (empfohlen wenn der Server nicht extern erreichbar ist)

Diese Methode ist besonders nützlich, wenn der Server nicht von überall erreichbar ist oder wenn SSH-Tunneling nicht möglich ist:

1. Verbinden Sie Ihren E-Mail-Client mit dem Proxy, um die Authentifizierung zu starten

2. In den Container-Logs wird eine Authentifizierungs-URL angezeigt:
   ```bash
   docker logs email-oauth2-proxy
   ```

3. Kopieren Sie diese URL und öffnen Sie sie in einem Browser auf Ihrem lokalen Rechner

4. Nach erfolgreicher Anmeldung werden Sie zu einer URL mit einem Code weitergeleitet. Diese URL beginnt mit `http://localhost:12345/...`

5. Kopieren Sie die vollständige URL und führen Sie auf dem Server folgenden Befehl aus:
   ```bash
   curl 'http://localhost:12345/...' # Ersetzen Sie dies mit der vollständigen Redirect-URL
   ```
   
   Dadurch wird die Authentifizierungsantwort direkt an den lokalen Server gesendet, ohne dass ein SSH-Tunnel benötigt wird.

### Methode 2: SSH-Tunneling

1. Starten Sie einen SSH-Tunnel von Ihrem lokalen Computer zum Server:
   ```bash
   ssh -L 12345:localhost:12345 benutzer@server-ip
   ```

2. Verbinden Sie Ihren E-Mail-Client mit dem Proxy, um die Authentifizierung zu starten

3. Öffnen Sie die Authentifizierungs-URL in Ihrem lokalen Browser
   - Die OAuth-Antwort wird durch den SSH-Tunnel zurück zum Container geleitet

## E-Mail-Client konfigurieren

Konfigurieren Sie Ihren E-Mail-Client mit den folgenden Einstellungen:

- **IMAP-Server**: IP-Adresse des Docker-Hosts
- **IMAP-Port**: 1143 (unverschlüsselt) oder 1993 (SSL/TLS)
- **POP3-Server**: IP-Adresse des Docker-Hosts
- **POP3-Port**: 1110 (unverschlüsselt) oder 1995 (SSL/TLS)
- **SMTP-Server**: IP-Adresse des Docker-Hosts
- **SMTP-Port**: 1025 (unverschlüsselt) oder 1587 (SSL/TLS)
- **Benutzername**: Ihre vollständige E-Mail-Adresse
- **Passwort**: Kann ein beliebiger Wert sein, da die OAuth-Authentifizierung separat erfolgt

## Shared Mailboxes verwenden

Email OAuth 2.0 Proxy unterstützt Office 365 Shared Mailboxes. Konfiguration:

1. Verwenden Sie die E-Mail-Adresse der Shared Mailbox in `EMAIL_ADDRESS`
2. Bei der Authentifizierung melden Sie sich mit einem Benutzerkonto an, das Zugriff auf die Shared Mailbox hat
3. Stellen Sie sicher, dass SMTP-Client-Authentifizierung im Tenant aktiviert ist

## Konfiguration

### Umgebungsvariablen in stack.env

| Variable | Beschreibung | Standard |
|----------|-------------|---------|
| `EMAIL_PROVIDER` | E-Mail-Anbieter (z.B. office365, gmail) | office365 |
| `CLIENT_ID` | OAuth 2.0 Client ID | (erforderlich) |
| `CLIENT_SECRET` | OAuth 2.0 Client Secret | (erforderlich) |
| `EMAIL_ADDRESS` | E-Mail-Adresse | (erforderlich) |
| `AUTH_URL` | OAuth 2.0 Autorisierungs-URL | https://login.microsoftonline.com/common/oauth2/v2.0/authorize |
| `TOKEN_URL` | OAuth 2.0 Token-URL | https://login.microsoftonline.com/common/oauth2/v2.0/token |
| `REDIRECT_URI` | OAuth 2.0 Redirect URI | http://localhost:12345/ |
| `REDIRECT_LISTEN` | Adresse, auf der der Proxy auf OAuth-Callbacks lauscht | http://0.0.0.0:12345/ |
| `DEBUG_MODE` | Debug-Modus aktivieren | false |
| `IMAP_PORT` | Lokaler IMAP-Port | 1143 |
| `IMAPS_PORT` | Lokaler IMAPS-Port | 1993 |
| `POP3_PORT` | Lokaler POP3-Port | 1110 |
| `POP3S_PORT` | Lokaler POP3S-Port | 1995 |
| `SMTP_PORT` | Lokaler SMTP-Port | 1025 |
| `SMTPS_PORT` | Lokaler SMTPS-Port | 1587 |
| `NETWORK_MODE` | Docker-Netzwerkmodus | bridge |

## Problembehandlung

### SMTP-Authentifizierung schlägt fehl

Wenn Sie die Fehlermeldung "smtpclientauthentication is disabled for the tenant" erhalten:

1. Melden Sie sich beim [Microsoft 365 Admin Center](https://admin.microsoft.com) an
2. Navigieren Sie zu "Einstellungen" → "Organisationseinstellungen" → "Sicherheit und Datenschutz" → "SMTP-Einstellungen"
3. Aktivieren Sie die Option "SMTP-Client-Authentifizierung"

### Authentifizierungsprobleme

Wenn die OAuth-Authentifizierung fehlschlägt:

1. Überprüfen Sie, ob die Redirect URI in Ihrer Azure App-Registrierung exakt mit `REDIRECT_URI` übereinstimmt
2. Stellen Sie sicher, dass Port 12345 nicht blockiert ist
3. Versuchen Sie die direkte Authentifizierung mit curl oder SSH-Tunneling
4. Prüfen Sie die Container-Logs mit `docker logs email-oauth2-proxy`
5. Aktivieren Sie den Debug-Modus mit `DEBUG_MODE=true`

### "No reply address is registered for the application"

Dieser Fehler bedeutet, dass die Redirect URI in Ihrer App-Registrierung fehlt oder nicht korrekt ist:

1. Gehen Sie zu Azure Portal → App-Registrierungen → Ihre App → Authentifizierung
2. Fügen Sie unter "Plattformkonfigurationen" → "Web" genau die gleiche URL hinzu, die Sie als `REDIRECT_URI` verwenden
3. Stellen Sie sicher, dass der Schrägstrich am Ende übereinstimmt (z.B. `http://localhost:12345/`)

### "Application is not configured as a multi-tenant application"

Wenn Ihre App als Single-Tenant konfiguriert ist, aber Sie den `/common`-Endpunkt verwenden:

1. In der `stack.env` setzen Sie `AUTH_URL` und `TOKEN_URL` so, dass sie Ihre spezifische Tenant-ID enthalten:
   ```
   AUTH_URL=https://login.microsoftonline.com/YOUR_TENANT_ID/oauth2/v2.0/authorize
   TOKEN_URL=https://login.microsoftonline.com/YOUR_TENANT_ID/oauth2/v2.0/token
   ```

2. Oder ändern Sie Ihre App in Azure zu "Multi-tenant":
   - Gehen Sie zu App-Registrierungen → Ihre App → Authentifizierung
   - Ändern Sie "Unterstützte Kontotypen" auf "Konten in einem beliebigen Organisationsverzeichnis"

## Automatische Updates

Das Docker-Image wird automatisch bei neuen Releases des originalen Email OAuth 2.0 Proxy-Projekts aktualisiert. Um immer die neueste Version zu verwenden, führen Sie regelmäßig:

```bash
docker-compose pull
docker-compose up -d
```

## Lizenz

Dieses Projekt basiert auf [Email OAuth 2.0 Proxy](https://github.com/simonrob/email-oauth2-proxy) und steht unter der [Apache 2.0 Lizenz](https://github.com/simonrob/email-oauth2-proxy/blob/main/LICENSE).

Entwickelt von [FoxTech e.U.](https://foxtech.at)
