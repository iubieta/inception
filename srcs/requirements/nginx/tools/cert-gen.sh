#!/bin/sh

DOMAIN=${DOMAIN_NAME:-iubieta-.42.fr}
DOMAIN=$(echo "$DOMAIN" | sed 's|https\?://||')
CERT_DIR="${CERT_DIR:-./secrets}"

mkdir -p "$CERT_DIR"

if [ -f "$CERT_DIR/site.crt" ] && [ -f "$CERT_DIR/site.key" ]; then
    exit 0
fi

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "$CERT_DIR/site.key" \
    -out "$CERT_DIR/site.crt" \
    -subj "/C=ES/ST=Madrid/L=Madrid/O=42/CN=${DOMAIN}" 2>/dev/null

chmod 600 "$CERT_DIR/site.key"
