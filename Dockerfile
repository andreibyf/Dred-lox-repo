FROM frappe/erpnext:v14

WORKDIR /home/frappe/frappe-bench

# Copy configuration files
COPY site_config.json /tmp/site_config.json
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Define environment variables
ENV SITE_NAME=microcrm.local \
    ADMIN_PASSWORD=admin \
    DB_ROOT_PASSWORD=root

# Switch to frappe user
USER frappe

# Site creation and app install
RUN bench new-site $SITE_NAME \
        --no-mariadb-socket \
        --mariadb-root-password=$DB_ROOT_PASSWORD \
        --admin-password=$ADMIN_PASSWORD \
        --force && \
    mv /tmp/site_config.json sites/$SITE_NAME/site_config.json && \
    bench get-app https://github.com/frappe/frappe_crm --branch version-14 && \
    bench --site $SITE_NAME install-app frappe_crm && \
    echo "webserver_port = 8000" >> sites/common_site_config.json

EXPOSE 8000

CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]


