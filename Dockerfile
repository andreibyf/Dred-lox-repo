FROM python:3.10-slim

# Environment setup
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /home/frappe

# Install system dependencies
RUN apt update && apt install -y \
    mariadb-server \
    redis-server \
    curl \
    git \
    supervisor \
    nodejs \
    npm \
    wkhtmltopdf \
    build-essential \
    libffi-dev \
    python3-dev \
    libssl-dev \
    libmysqlclient-dev \
    && apt clean

# Install bench
RUN pip install frappe-bench && bench init frappe-bench --frappe-branch version-14

WORKDIR /home/frappe/frappe-bench

# Create site (you can automate this with a script later)
COPY site_config.json sites/microcrm.local/site_config.json
RUN bench new-site microcrm.local --no-mariadb-socket --mariadb-root-password=root --admin-password=admin
RUN bench get-app https://github.com/frappe/frappe_crm --branch version-14
RUN bench --site microcrm.local install-app frappe_crm

# Bind to 0.0.0.0
RUN echo "webserver_port = 8000" >> sites/common_site_config.json

# Start everything through supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord"]

