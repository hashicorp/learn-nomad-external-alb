#!/bin/bash

NOMAD_USER_TOKEN_FILENAME="nomad.token"

# Get secret from tfvars file
TOKEN_SECRET=$(grep nomad_consul_token_secret terraform.tfvars | awk -F '"' '{print $2}')
LB_ADDRESS=$(terraform output -raw lb_address)
CONSUL_BOOTSTRAP_TOKEN=$(terraform output -raw consul_bootstrap_token_secret)

# Get nomad user token from consul kv
NOMAD_TOKEN=$(curl -s --header "Authorization: Bearer ${TOKEN_SECRET}" "${LB_ADDRESS}:8500/v1/kv/nomad_user_token?raw")

# Save token to file
if [ ! -f $NOMAD_USER_TOKEN_FILENAME ]; then
    echo $NOMAD_TOKEN > $NOMAD_USER_TOKEN_FILENAME

    # Delete nomad user token from consul kv
    DELETE_TOKEN=$(curl -s -X DELETE --header "Authorization: Bearer ${TOKEN_SECRET}" "${LB_ADDRESS}:8500/v1/kv/nomad_user_token")

    echo -e "\nThe Nomad user token has been saved locally to $NOMAD_USER_TOKEN_FILENAME and deleted from the Consul KV store."

    echo -e "\nSet the following environment variables to access your Nomad cluster with the user token created during setup:\n\nexport NOMAD_ADDR=${LB_ADDRESS}:4646\nexport NOMAD_TOKEN=\$(cat $NOMAD_USER_TOKEN_FILENAME)\n"
else 
    echo -e "\n***\nThe $NOMAD_USER_TOKEN_FILENAME file already exists - not overwriting. If this is a new run, delete it first.\n***"
fi