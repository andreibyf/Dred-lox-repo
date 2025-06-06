#!/bin/bash
set -e

SITE_NAME=${SITE_NAME:-"site.local"}
DB_ROOT_PASSWORD=${DB_ROOT_PASSWORD:-"root"}
ADMIN_PASSWORD=${ADMIN_PASSWORD:-"admin"}

# Check if site already exists
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
else
  echo "Site $SITE_NAME already exists. Skipping creation."
fi

# Start supervisor
exec supervisord -c /etc/supervisor/conf.d/supervisord.conf
