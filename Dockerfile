# ✅ Use official ERPNext v14 base image (includes Frappe + MariaDB + Redis + Node)
FROM frappe/erpnext:v14

# Set working directory
WORKDIR /home/frappe/frappe-bench

# Copy site config (ensure this file exists in your repo)
COPY site_config.json sites/microcrm.local/site_config.json

# Create new site (mariadb already running inside image)
RUN bench new-site microcrm.local --no-mariadb-socket --mariadb-root-password=root --admin-password=admin --force

# Get and install frappe_crm (or other apps if needed)
RUN bench get-app https://github.com/frappe/frappe_crm --branch version-14
RUN bench --site microcrm.local install-app frappe_crm

# Set correct port for Gunicorn
RUN echo "webserver_port = 8000" >> sites/common_site_config.json

# Copy supervisord config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose web port
EXPOSE 8000

# Start app
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

