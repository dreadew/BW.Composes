#!bin/bash

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

helm install keycloak bitnami/keycloak -n authorization \
  --set auth.adminUser=admin \
  --set auth.adminPassword=admin \
  --set service.type=LoadBalancer

kubectl wait --for=condition=available --timeout=600s deployment/keycloak --namespace authorization

KEYCLOAK_URL=$(kubectl get svc keycloak -n authorization -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

REALM_NAME="local-realm"
CLIENT_ID="aspnet-core-client"
CLIENT_SECRET="clientsecret"

KEYCLOAK_BIN_PATH="/opt/keycloak/bin"
KEYCLOAK_ADMIN_USER="admin"
KEYCLOAK_ADMIN_PASSWORD="admin"

echo "Configuring kcadm.sh"
kubectl cp keycloak:/opt/keycloak/bin/kcadm.sh /tmp/kcadm.sh
chmod +x /tmp/kcadm.sh

echo "Signing in to Keycloak"
/tmp/kcadm.sh config credentials --server http://$KEYCLOAK_URL:8080 --realm master --user $KEYCLOAK_ADMIN_USER --password $KEYCLOAK_ADMIN_PASSWORD

echo "Creating realm $REALM_NAME"
/tmp/kcadm.sh create realms -s realm=$REALM_NAME -s enabled=true

echo "Creating client $CLIENT_ID"
/tmp/kcadm.sh create clients -r $REALM_NAME -s clientId=$CLIENT_ID -s rootUrl="http://localhost" \
  -s 'redirectUris=["http://localhost/*"]' -s 'publicClient=false' -s 'accessType=CONFIDENTIAL'

CLIENT_ID_CREATED=$(/tmp/kcadm.sh get clients -r $REALM_NAME --query "clientId=$CLIENT_ID" | jq -r '.[0].id')

echo "Creating client secret for $CLIENT_ID"
/tmp/kcadm.sh set clients/$CLIENT_ID_CREATED/credentials -r $REALM_NAME -s value=$CLIENT_SECRET