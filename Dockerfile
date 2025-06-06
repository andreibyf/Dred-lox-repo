# Base image with ERPNext, MariaDB, Redis, Node.js preinstalled
FROM frappe/erpnext:v14

# Set working directory
WORKDIR /home/frappe/frappe-bench

# Provide environment variables during build
ENV SITE_NAME=microcrm.local \
    DB_ROOT_PASSWORD=root \
    ADMIN_PASSWORD=admin

# Create necessary site directory and write site_config.json with Redis and DB credentials
RUN mkdir -p sites/${SITE_NAME} && \
    cat <<EOF > sites/${SITE_NAME}/site_config.json
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

# Create the Frappe site, install CRM app, configure web port
RUN bench new-site ${SITE_NAME} --no-mariadb-socket --force && \
    bench get-app https://github.com/frappe/frappe_crm --branch version-14 && \
    bench --site ${SITE_NAME} install-app frappe_crm && \
    echo "webserver_port = 8000" >> sites/common_site_config.json

# Copy supervisor config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose application port
EXPOSE 8000

# Start supervisor (manages web workers, Redis, etc.)
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
