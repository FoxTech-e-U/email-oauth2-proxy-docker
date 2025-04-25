#!/bin/bash
set -e

CONFIG_FILE="/config/emailproxy.config"
EXAMPLE_CONFIG_FILE="/config/emailproxy.config.example"

# Funktion zur Erstellung der Konfigurationsdatei
create_config() {
    echo "Erstelle neue Konfigurationsdatei aus Umgebungsvariablen..."
    
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
redirect_uri = $REDIRECT_URI
redirect_listen_address = ${REDIRECT_LISTEN:-http://0.0.0.0:12345/}
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
oauth2_redirect_listen_address = ${REDIRECT_LISTEN:-http://0.0.0.0:12345/}
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
}

# Prüfen, ob eine Konfigurationsdatei existiert
if [ ! -f "$CONFIG_FILE" ]; then
    create_config
else
    echo "Bestehende Konfigurationsdatei gefunden. Prüfe ob sie valide ist..."
    
    # Versuche die Konfigurationsdatei zu validieren
    if grep -q "type.*office365" "$CONFIG_FILE"; then
        echo "Fehlerhafte Konfigurationsdatei gefunden. Erstelle Backup und generiere neu..."
        # Erstelle ein Backup der alten Konfiguration
        cp "$CONFIG_FILE" "${CONFIG_FILE}.backup-$(date +%Y%m%d%H%M%S)"
        # Erstelle neue Konfiguration
        create_config
    else
        echo "Bestehende Konfigurationsdatei scheint valide zu sein. Verwende vorhandene Konfiguration."
    fi
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
