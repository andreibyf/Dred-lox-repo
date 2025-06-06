# ✅ Use official ERPNext v14 base image (includes Frappe, MariaDB, Redis, Node)
FROM frappe/erpnext:v14

# Set working directory inside the container
WORKDIR /home/frappe/frappe-bench

# Environment variables will be injected by Fly via secrets or [env] block
ENV SITE_NAME=$SITE_NAME \
    ADMIN_PASSWORD=$ADMIN_PASSWORD \
    DB_ROOT_PASSWORD=$DB_ROOT_PASSWORD \
    INSTALL_APPS=frappe_crm

# Pre-create site directory to avoid move errors
RUN mkdir -p sites/${SITE_NAME}

# Copy site_config.json to temporary location in container
COPY site_config.json /tmp/site_config.json

# Site setup: create site, move config, get app, install app, set webserver port
RUN bench new-site ${SITE_NAME} \
        --no-mariadb-socket \
        --mariadb-root-password=${DB_ROOT_PASSWORD} \
        --admin-password=${ADMIN_PASSWORD} \
        --force && \
    mv /tmp/site_config.json sites/${SITE_NAME}/site_config.json && \
    bench get-app https://github.com/frappe/frappe_crm --branch version-14 && \
    bench --site ${SITE_NAME} install-app frappe_crm && \
    echo "webserver_port = 8000" >> sites/common_site_config.json

# Copy supervisor config to start app
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose Gunicorn port
EXPOSE 8000

# Start Supervisor on container boot
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]



