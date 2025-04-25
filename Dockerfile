FROM python:3.10-slim

# Labels für bessere Wartbarkeit
LABEL maintainer="FoxTech e.U. <office@foxtech.at>"
LABEL description="Email OAuth 2.0 Proxy - Add OAuth 2.0 support to email clients"
LABEL source="https://github.com/simonrob/email-oauth2-proxy"

# Arbeitsverzeichnis erstellen
WORKDIR /app

# Abhängigkeiten installieren (nur Core-Abhängigkeiten, ohne GUI)
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libc6-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Setze umgebungsvariablen
ENV EMAIL_PROVIDER=office365 \
    CLIENT_ID="" \
    CLIENT_SECRET="" \
    EMAIL_ADDRESS="" \
    REDIRECT_URI="http://localhost:12345/" \
    DEBUG_MODE=false

# Kopiere requirements und installiere sie
COPY requirements-core.txt .
RUN pip install --no-cache-dir -r requirements-core.txt

# Kopiere Anwendungsdateien
COPY emailproxy.py .
COPY emailproxy.config /config/emailproxy.config.example
COPY entrypoint.sh /app/entrypoint.sh

# Entrypoint-Skript ausführbar machen
RUN chmod +x /app/entrypoint.sh

# Volume für persistente Konfiguration und Tokens
VOLUME ["/config"]

# Ports für die Standard-E-Mail-Protokolle freigeben
# IMAP
EXPOSE 1143 1993
# POP3
EXPOSE 1110 1995
# SMTP
EXPOSE 1025 1587

# Starte die Anwendung über das Entrypoint-Skript
ENTRYPOINT ["/app/entrypoint.sh"]
