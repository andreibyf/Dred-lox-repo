# ✅ Use official ERPNext v14 base image (includes Frappe, MariaDB, Redis, Node)
FROM frappe/erpnext:v14

# Set working directory
WORKDIR /home/frappe/frappe-bench

# Set required envs and generate site_config.json manually before creating the site
ENV SITE_NAME=$SITE_NAME \
    ADMIN_PASSWORD=$ADMIN_PASSWORD \
    DB_ROOT_PASSWORD=$DB_ROOT_PASSWORD \
    INSTALL_APPS=frappe_crm

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

# Now create the site, install app, and set port
RUN bench new-site ${SITE_NAME} --no-mariadb-socket --force && \
    bench get-app https://github.com/frappe/frappe_crm --branch version-14 && \
    bench --site ${SITE_NAME} install-app frappe_crm && \
    echo "webserver_port = 8000" >> sites/common_site_config.json

# Copy supervisor config to start app
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose Gunicorn port
EXPOSE 8000

# Start Supervisor on container boot
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
