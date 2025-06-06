FROM frappe/erpnext:v14

# Set working directory
WORKDIR /home/frappe/frappe-bench

# Copy config
COPY site_config.json sites/microcrm.local/site_config.json
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Fix file ownership
RUN chown -R frappe:frappe /home/frappe/frappe-bench

# Use the frappe user to run bench commands
USER frappe

# Create site
RUN bench new-site microcrm.local --no-mariadb-socket --mariadb-root-password=root --admin-password=admin --force
RUN bench get-app https://github.com/frappe/frappe_crm --branch version-14
RUN bench --site microcrm.local install-app frappe_crm
RUN echo "webserver_port = 8000" >> sites/common_site_config.json

# Expose port and run
EXPOSE 8000
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
