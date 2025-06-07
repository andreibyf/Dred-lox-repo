#!/bin/bash
set -e

SITE_NAME=${SITE_NAME:-"site.local"}
DB_ROOT_PASSWORD=${DB_ROOT_PASSWORD:?DB root password not set}
ADMIN_PASSWORD=${ADMIN_PASSWORD:?Admin password not set}

# Create site_config.json before running bench
mkdir -p sites/${SITE_NAME}
cat > sites/${SITE_NAME}/site_config.json <<EOF
{
  "db_name": "${SITE_NAME}",
  "db_password": "${DB_ROOT_PASSWORD}",
  "admin_password": "${ADMIN_PASSWORD}",
  "redis_cache": "redis://localhost:6379",
  "redis_queue": "redis://localhost:6379",
  "redis_socketio": "redis://localhost:6379",
  "socketio_port": 9000
}
EOF

# Start Redis
redis-server --daemonize yes

# Only create site if it doesn't already exist
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

# Patch port setting
if [ -f sites/common_site_config.json ]; then
  python3 -c "
import json
with open('sites/common_site_config.json') as f:
  data = json.load(f)
data['webserver_port'] = 8000
with open('sites/common_site_config.json', 'w') as f:
  json.dump(data, f)
"
fi

exec bench start
