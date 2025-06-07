FROM frappe/erpnext:v14

WORKDIR /home/frappe/frappe-bench

# Root to copy + chmod
USER root
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
RUN apt-get update && apt-get install -y redis-server && rm -rf /var/lib/apt/lists/*
RUN pip3 install gunicorn

# Switch back to frappe user
USER frappe

EXPOSE 8000
ENTRYPOINT ["/entrypoint.sh"]
