FROM frappe/erpnext:v14

WORKDIR /home/frappe/frappe-bench

# Temporarily switch to root to install jq and copy entrypoint
USER root
RUN apt update && apt install -y jq

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Switch back to frappe user
USER frappe

EXPOSE 8000

ENTRYPOINT ["/entrypoint.sh"]