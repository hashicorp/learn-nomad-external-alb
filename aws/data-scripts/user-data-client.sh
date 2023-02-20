#!/bin/bash
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0


set -e

exec > >(sudo tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
sudo bash /ops/shared/scripts/client.sh "aws" "${retry_join}" "${nomad_binary}"

NOMAD_HCL_PATH="/etc/nomad.d/nomad.hcl"

sed -i "s/CONSUL_TOKEN/${nomad_consul_token_secret}/g" $NOMAD_HCL_PATH

# Place the AWS instance name as metadata on the
# client for targetting workloads
AWS_SERVER_TAG_NAME=$(curl http://169.254.169.254/latest/meta-data/tags/instance/Name)
sed -i "s/SERVER_NAME/$AWS_SERVER_TAG_NAME/g" $NOMAD_HCL_PATH

# Put targeted nodes in a different datacenter
# and add service_client meta tag
if [[ $AWS_SERVER_TAG_NAME =~ "targeted" ]]; then
    sed -i "s/DATACENTER/dc2/g" $NOMAD_HCL_PATH
    sed -i "s/SERVICE_CLIENT/payments/g" $NOMAD_HCL_PATH
else
    sed -i "s/DATACENTER/dc1/g" $NOMAD_HCL_PATH
    sed -i "s/SERVICE_CLIENT/api/g" $NOMAD_HCL_PATH
fi

sudo systemctl restart nomad