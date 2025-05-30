#!/bin/sh
vault server -config vault-config.hcl

export VAULT_ADDR='https://0.0.0.0:8201'
export VAULT_SKIP_VERIFY='true'

# mapfile -t keyArray < <( grep "Unseal Key " < generated_keys.txt  | cut -c15- )

# vault operator unseal ${keyArray[0]}
# vault operator unseal ${keyArray[1]}
# vault operator unseal ${keyArray[2]}

# mapfile -t rootToken < <(grep "Initial Root Token: " < generated_keys.txt  | cut -c21- )
# echo ${rootToken[0]} > root_token.txt

# export VAULT_TOKEN=${rootToken[0]}

# vault secrets enable -version=1 kv

# vault auth enable userpass
# vault policy write asp-policy policy.hcl
# vault write auth/userpass/users/admin password=admin policies=asp-policy