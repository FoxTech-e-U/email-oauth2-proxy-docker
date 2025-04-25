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

[Server setup]
# Konfiguration basierend auf den Umgebungsvariablen

EOL

    # Provider-spezifische Konfiguration auf Basis der Umgebungsvariablen
    if [ "$EMAIL_PROVIDER" = "office365" ]; then
        cat >> "$CONFIG_FILE" << EOL
[IMAP-1143]
server_address = outlook.office365.com
server_port = 993
local_address = 0.0.0.0
ssl = True

[IMAPS-1993]
server_address = outlook.office365.com
server_port = 993
local_address = 0.0.0.0
ssl = True

[POP-1110]
server_address = outlook.office365.com
server_port = 995
local_address = 0.0.0.0
ssl = True

[POP3S-1995]
server_address = outlook.office365.com
server_port = 995
local_address = 0.0.0.0
ssl = True

[SMTP-1025]
server_address = smtp.office365.com
server_port = 587
server_starttls = True
local_address = 0.0.0.0

[SMTPS-1587]
server_address = smtp.office365.com
server_port = 587
server_starttls = True
local_address = 0.0.0.0

[Account setup]
# Office 365 Konto-Konfiguration

[$EMAIL_ADDRESS]
permission_url = https://login.microsoftonline.com/common/oauth2/v2.0/authorize
token_url = https://login.microsoftonline.com/common/oauth2/v2.0/token
oauth2_scope = offline_access https://outlook.office.com/IMAP.AccessAsUser.All https://outlook.office.com/POP.AccessAsUser.All https://outlook.office.com/SMTP.Send
oauth2_redirect_uri = $REDIRECT_URI
client_id = $CLIENT_ID
client_secret = $CLIENT_SECRET
EOL

    elif [ "$EMAIL_PROVIDER" = "gmail" ]; then
        cat >> "$CONFIG_FILE" << EOL
[IMAP-1143]
server_address = imap.gmail.com
server_port = 993
local_address = 0.0.0.0
ssl = True

[IMAPS-1993]
server_address = imap.gmail.com
server_port = 993
local_address = 0.0.0.0
ssl = True

[POP-1110]
server_address = pop.gmail.com
server_port = 995
local_address = 0.0.0.0
ssl = True

[POP3S-1995]
server_address = pop.gmail.com
server_port = 995
local_address = 0.0.0.0
ssl = True

[SMTP-1025]
server_address = smtp.gmail.com
server_port = 587
server_starttls = True
local_address = 0.0.0.0

[SMTPS-1587]
server_address = smtp.gmail.com
server_port = 587
server_starttls = True
local_address = 0.0.0.0

[Account setup]
# Gmail Konto-Konfiguration

[$EMAIL_ADDRESS]
permission_url = https://accounts.google.com/o/oauth2/auth
token_url = https://oauth2.googleapis.com/token
oauth2_scope = https://mail.google.com/
oauth2_redirect_uri = $REDIRECT_URI
client_id = $CLIENT_ID
client_secret = $CLIENT_SECRET
EOL

    else
        echo "Warnung: Unbekannter E-Mail-Provider '$EMAIL_PROVIDER'. Bitte konfiguriere die Datei $CONFIG_FILE manuell."
    fi
    
    # Zusätzliche Proxy-Einstellungen
    cat >> "$CONFIG_FILE" << EOL

[Advanced proxy configuration]
delete_account_token_on_password_error = True
encrypt_client_secret_on_first_use = False
use_login_password_as_client_credentials_secret = False
allow_catch_all_accounts = False
EOL
    
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
