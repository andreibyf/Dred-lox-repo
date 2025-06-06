FROM frappe/erpnext:v14

WORKDIR /home/frappe/frappe-bench

# Copy runtime init script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Optional: Set port
RUN echo "webserver_port = 8000" >> sites/common_site_config.json

# Expose port
EXPOSE 8000

# Run the init script (runtime site creation)
CMD ["/entrypoint.sh"]
