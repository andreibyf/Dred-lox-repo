FROM frappe/erpnext:v14

WORKDIR /home/frappe/frappe-bench

# Copy files to a temp location (root can write here)
COPY site_config.json /tmp/site_config.json
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

USER frappe

# Now run as frappe: move the config and create site
RUN mv /tmp/site_config.json sites/microcrm.local/site_config.json && \
    bench new-site microcrm.local --no-mariadb-socket --mariadb-root-password=root --admin-password=admin --force && \
    bench get-app https://github.com/frappe/frappe_crm --branch version-14 && \
    bench --site microcrm.local install-app frappe_crm && \
    echo "webserver_port = 8000" >> sites/common_site_config.json

EXPOSE 8000

CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

