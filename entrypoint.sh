#!/bin/bash
set -e

SITE_NAME=${SITE_NAME:-"site.local"}
DB_ROOT_PASSWORD=${DB_ROOT_PASSWORD:-"root"}
ADMIN_PASSWORD=${ADMIN_PASSWORD:-"admin"}

# Install jq (for clean JSON patching)
apt update && apt install -y jq

# Create site if not exists
if [ ! -d "sites/$SITE_NAME" ]; then
  echo "Creating site: $SITE_NAME"

  bench new-site "$SITE_NAME" \
    --no-mariadb-socket \
    --mariadb-root-password="$DB_ROOT_PASSWORD" \
    --admin-password="$ADMIN_PASSWORD" \
    --force

  echo "Installing frappe_crm"
  bench get-app https://github.com/frappe/frappe_crm --branch version-14
  bench --site "$SITE_NAME" install-app frappe_crm
fi

# Patch common_site_config.json safely
if [ -f sites/common_site_config.json ]; then
  jq 'if has("webserver_port") then . else . + { "webserver_port": 8000 } end' \
    sites/common_site_config.json > sites/tmp.json && \
    mv sites/tmp.json sites/common_site_config.json
fi

# Start Frappe using Gunicorn
exec bench start
