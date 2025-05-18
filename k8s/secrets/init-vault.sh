#!/bin/bash

VAULT_ADDR="http://localhost:8525"
OUTPUT_DIR="./vault-tokens"
INIT_FILE="$OUTPUT_DIR/init.json"
UNSEAL_KEYS_FILE="$OUTPUT_DIR/unseal-keys.txt"
ROOT_TOKEN_FILE="$OUTPUT_DIR/root-token.txt"

mkdir -p "$OUTPUT_DIR"

until curl -s "$VAULT_ADDR/v1/sys/health" | grep -q "initialized"; do
  sleep 2
done

if vault status | grep -q 'Initialized.*true'; then
  echo "⚠️ Vault уже инициализирован."
  exit 0
fi

vault operator init -format=json > "$INIT_FILE"

jq -r '.unseal_keys_b64[]' "$INIT_FILE" > "$UNSEAL_KEYS_FILE"
jq -r '.root_token' "$INIT_FILE" > "$ROOT_TOKEN_FILE"

i=0
while read -r key; do
  echo "  > Ключ $((++i))"
  vault operator unseal "$key"
  if [ "$i" -eq 3 ]; then break; fi
done < "$UNSEAL_KEYS_FILE"

vault login "$(cat "$ROOT_TOKEN_FILE")"
