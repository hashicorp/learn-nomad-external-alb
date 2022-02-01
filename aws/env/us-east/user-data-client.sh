#!/bin/bash

set -e

exec > >(sudo tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
sudo bash /ops/shared/scripts/client.sh "aws" "${retry_join}" "${nomad_binary}"

sed -i "s/CONSUL_TOKEN/${nomad_consul_token_secret}/g" /etc/nomad.d/nomad.hcl

sudo systemctl restart nomad

# Get token from consul kv
# echo 'Getting Nomad token from KV store'
# consul kv get nomad/bootstrap-token
# while [ $? -ne 0 ]; do 
#   sleep 2
#   consul kv get nomad/bootstrap-token
# done
# NOMAD_CONSUL_TOKEN="$(consul kv get nomad/bootstrap-token)"
# sed -i "s/CONSUL_TOKEN/$NOMAD_CONSUL_TOKEN/g" $NOMADCONFIGDIR/nomad.hcl