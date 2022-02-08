#!/bin/bash

set -e

exec > >(sudo tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
sudo bash /ops/shared/scripts/client.sh "aws" "${retry_join}" "${nomad_binary}"

sed -i "s/CONSUL_TOKEN/${nomad_consul_token_secret}/g" /etc/nomad.d/nomad.hcl

# Place the AWS instance name as metadata on the
# client for targetting workloads
AWS_SERVER_TAG_NAME=$(curl http://169.254.169.254/latest/meta-data/tags/instance/Name)
sed -i "s/SERVER_NAME/$AWS_SERVER_TAG_NAME/g" /etc/nomad.d/nomad.hcl

sudo systemctl restart nomad