# Base image
FROM frappe/frappe:v14

# Set working directory
WORKDIR /home/frappe

# Install any extra system packages (you can expand this as needed)
RUN apt update && apt install -y \
    mariadb-client \
    redis-tools \
    curl \
    git \
    supervisor \
    && apt clean

# Init frappe bench (skip if you already have it in base image)
RUN pip install frappe-bench && bench init frappe-bench --frappe-branch version-14

WORKDIR /home/frappe/frappe-bench

# Create new site
COPY site_config.json sites/microcrm.local/site_config.json
RUN bench new-site microcrm.local --no-mariadb-socket --mariadb-root-password=root --admin-password=admin

# Add frappe_crm app
RUN bench get-app https://github.com/frappe/frappe_crm --branch version-14
RUN bench --site microcrm.local install-app frappe_crm

# Set port for webserver (Gunicorn will bind here)
RUN echo "webserver_port = 8000" >> sites/common_site_config.json

# Copy supervisor config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose port
EXPOSE 8000

# Start services
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
