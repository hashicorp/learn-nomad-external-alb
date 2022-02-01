#!/bin/bash

# Get secret from tfvars file
TOKEN_SECRET=$(grep nomad_consul_token_secret terraform.tfvars | awk -F '"' '{print $2}')
LB_ADDRESS=$(terraform output -raw lb_address)

# Get nomad user token from consul kv
NOMAD_TOKEN=$(curl -s -w '\n' --header "Authorization: Bearer ${TOKEN_SECRET}" "${LB_ADDRESS}:8500/v1/kv/nomad_user_token?raw")
echo -e "Set the following environment variables to access your Nomad cluster with the user token created during setup:\n\nexport NOMAD_ADDR=${LB_ADDRESS}:4646\nexport NOMAD_TOKEN=$NOMAD_TOKEN\n"

# TODO: Delete user token from consul kv