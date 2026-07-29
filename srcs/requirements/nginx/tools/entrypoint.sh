#!/bin/sh

DOMAIN=${DOMAIN_NAME:-iubieta-.42.fr}
DOMAIN=$(echo "$DOMAIN" | sed 's|https\?://||')

sed -i "s/__DOMAIN_NAME__/${DOMAIN}/g" /etc/nginx/conf.d/default.conf

exec nginx -g "daemon off;"
