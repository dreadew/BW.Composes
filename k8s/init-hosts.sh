#!/bin/bash
IP=$(minikube ip)
HOSTNAMES=(
    messaging.local
    data.local
    monitoring.local
    storage.local
)

for HOSTNAME in "${HOSTNAMES[@]}"; do
    if grep -q "$HOSTNAME" /etc/hosts; then
        echo "host entry for $HOSTNAME already exists."
    else
        echo "adding host entry for $HOSTNAME..."
        echo "$IP $HOSTNAME" | sudo tee -a /etc/hosts > /dev/null
    fi
done

echo "hosts:"
for HOSTNAME in "${HOSTNAMES[@]}"; do
  echo "→ http://$HOSTNAME"
done