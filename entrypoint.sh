#!/bin/bash
set -e

SITE_NAME=${SITE_NAME:-"site.local"}
DB_ROOT_PASSWORD=${DB_ROOT_PASSWORD:-"root"}
ADMIN_PASSWORD=${ADMIN_PASSWORD:-"admin"}

# Create site only if it doesn't exist
if [ ! -d "sites/$SITE_NAME" ]; then
  echo "Creating site: $SITE_NAME"

  bench new-site "$SITE_NAME" \
    --no-mariadb-socket \
    --mariadb-root-password="$DB_ROOT_PASSWORD" \
    --admin-password="$ADMIN_PASSWORD"

  echo "Installing frappe_crm"
  bench get-app https://github.com/frappe/frappe_crm --branch version-14
  bench --site "$SITE_NAME" install-app frappe_crm

  # Patch common_site_config.json right after new-site
  python3 -c "
import json
f = 'sites/common_site_config.json'
with open(f) as file:
    d = json.load(file)
d['webserver_port'] = 8000
with open(f, 'w') as file:
    json.dump(d, file)
"
fi

# Start Frappe
exec bench start
