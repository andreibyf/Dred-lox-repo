FROM frappe/erpnext:v14

WORKDIR /home/frappe/frappe-bench

# Temporarily switch to root to copy and chmod the entrypoint. Copy runtime init script
USER root
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Switch back to frappe user
USER frappe

# Optional: Set port
RUN echo "webserver_port = 8000" >> sites/common_site_config.json

# Expose port
EXPOSE 8000

# Run the init script (runtime site creation)
CMD ["/entrypoint.sh"]
