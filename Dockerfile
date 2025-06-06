# Set required envs and generate site_config.json manually before creating the site
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



