#!/bin/bash

set -e

exec > >(sudo tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
sudo bash /ops/shared/scripts/client.sh "aws" "${retry_join}" "${nomad_binary}"

sed -i "s/CONSUL_TOKEN/${nomad_consul_token_secret}/g" /etc/nomad.d/nomad.hcl

sudo systemctl restart nomad