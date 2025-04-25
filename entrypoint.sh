#!/bin/bash
set -e

CONFIG_FILE="/config/emailproxy.config"
EXAMPLE_CONFIG_FILE="/config/emailproxy.config.example"

# Prüfen ob eine Konfigurationsdatei existiert, wenn nicht, erstelle eine aus den Umgebungsvariablen
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Keine Konfigurationsdatei gefunden. Erstelle Konfiguration aus Umgebungsvariablen..."
    
    # Grundgerüst für die Konfigurationsdatei
    cat > "$CONFIG_FILE" << EOL
[DEFAULT]
local_server_auth = True

EOL

    # Provider-spezifische Konfiguration auf Basis der Umgebungsvariablen
    if [ "$EMAIL_PROVIDER" = "office365" ]; then
        cat >> "$CONFIG_FILE" << EOL
[Office365]
type = IMAP
local_address = 0.0.0.0
local_port = 1143
remote_address = outlook.office365.com
remote_port = 993
ssl = True

type = IMAPS
local_address = 0.0.0.0
local_port = 1993
remote_address = outlook.office365.com
remote_port = 993
ssl = True

type = POP
local_address = 0.0.0.0
local_port = 1110
remote_address = outlook.office365.com
remote_port = 995
ssl = True

type = POP3S
local_address = 0.0.0.0
local_port = 1995
remote_address = outlook.office365.com
remote_port = 995
ssl = True

type = SMTP
local_address = 0.0.0.0
local_port = 1025
remote_address = smtp.office365.com
remote_port = 587
ssl = STARTTLS

type = SMTPS
local_address = 0.0.0.0
local_port = 1587
remote_address = smtp.office365.com
remote_port = 587
ssl = STARTTLS

[Office365:$EMAIL_ADDRESS]
oauth2_client_id = $CLIENT_ID
oauth2_client_secret = $CLIENT_SECRET
oauth2_scope = offline_access https://outlook.office.com/IMAP.AccessAsUser.All https://outlook.office.com/POP.AccessAsUser.All https://outlook.office.com/SMTP.Send
oauth2_redirect_uri = $REDIRECT_URI
oauth2_token_endpoint = https://login.microsoftonline.com/common/oauth2/v2.0/token
oauth2_auth_endpoint = https://login.microsoftonline.com/common/oauth2/v2.0/authorize
EOL

    elif [ "$EMAIL_PROVIDER" = "gmail" ]; then
        cat >> "$CONFIG_FILE" << EOL
[Gmail]
type = IMAP
local_address = 0.0.0.0
local_port = 1143
remote_address = imap.gmail.com
remote_port = 993
ssl = True

type = IMAPS
local_address = 0.0.0.0
local_port = 1993
remote_address = imap.gmail.com
remote_port = 993
ssl = True

type = POP
local_address = 0.0.0.0
local_port = 1110
remote_address = pop.gmail.com
remote_port = 995
ssl = True

type = POP3S
local_address = 0.0.0.0
local_port = 1995
remote_address = pop.gmail.com
remote_port = 995
ssl = True

type = SMTP
local_address = 0.0.0.0
local_port = 1025
remote_address = smtp.gmail.com
remote_port = 587
ssl = STARTTLS

type = SMTPS
local_address = 0.0.0.0
local_port = 1587
remote_address = smtp.gmail.com
remote_port = 587
ssl = STARTTLS

[Gmail:$EMAIL_ADDRESS]
oauth2_client_id = $CLIENT_ID
oauth2_client_secret = $CLIENT_SECRET
oauth2_scope = https://mail.google.com/
oauth2_redirect_uri = $REDIRECT_URI
EOL

    else
        echo "Warnung: Unbekannter E-Mail-Provider '$EMAIL_PROVIDER'. Bitte konfiguriere die Datei $CONFIG_FILE manuell."
    fi
    
    echo "Konfigurationsdatei wurde erstellt."
else
    echo "Bestehende Konfigurationsdatei gefunden. Verwende vorhandene Konfiguration."
fi

# Debug-Modus aktivieren, wenn gewünscht
if [ "$DEBUG_MODE" = "true" ]; then
    echo "Debug-Modus aktiviert."
    EXTRA_ARGS="--debug"
else
    EXTRA_ARGS=""
fi

# Start des Email OAuth 2.0 Proxy
echo "Starte Email OAuth 2.0 Proxy..."
exec python emailproxy.py --no-gui --config-file "$CONFIG_FILE" --local-server-auth $EXTRA_ARGS
