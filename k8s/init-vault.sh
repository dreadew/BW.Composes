#!/bin/bash

set -e

NAMESPACE="secrets"
RELEASE_NAME="vault"
OUTPUT_DIR="./vault-tokens"
INIT_FILE="$OUTPUT_DIR/init.json"
UNSEAL_KEYS_FILE="$OUTPUT_DIR/unseal-keys.txt"
ROOT_TOKEN_FILE="$OUTPUT_DIR/root-token.txt"

kubectl get namespace $NAMESPACE >/dev/null 2>&1 || kubectl create namespace $NAMESPACE

helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

helm upgrade --install $RELEASE_NAME hashicorp/vault \
  --namespace $NAMESPACE \
  --set "server.dev.enabled=false" \
  --set "server.ha.enabled=false" \
  --wait

mkdir -p "$OUTPUT_DIR"

kubectl -n $NAMESPACE wait --for=condition=ready pod -l app.kubernetes.io/name=vault --timeout=180s

VAULT_POD=$(kubectl -n $NAMESPACE get pods -l app.kubernetes.io/name=vault -o jsonpath='{.items[0].metadata.name}')

if kubectl -n $NAMESPACE exec $VAULT_POD -- vault status | grep -q 'Initialized.*true'; then
  echo "vault already initialized"
  exit 0
fi

kubectl -n $NAMESPACE exec $VAULT_POD -- vault operator init -format=json > "$INIT_FILE"

jq -r '.unseal_keys_b64[]' "$INIT_FILE" > "$UNSEAL_KEYS_FILE"
jq -r '.root_token' "$INIT_FILE" > "$ROOT_TOKEN_FILE"

i=0
while read -r key; do
  echo "  > unseal key $((++i))"
  kubectl -n $NAMESPACE exec $VAULT_POD -- vault operator unseal "$key"
  if [ "$i" -eq 3 ]; then break; fi
done < "$UNSEAL_KEYS_FILE"

kubectl -n $NAMESPACE exec $VAULT_POD -- vault login "$(cat "$ROOT_TOKEN_FILE")"

echo "tokens saved in: $OUTPUT_DIR"
