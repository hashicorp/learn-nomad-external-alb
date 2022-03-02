#!/bin/bash

set -e

exec > >(sudo tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
sudo bash /ops/shared/scripts/server.sh "aws" "${server_count}" "${retry_join}" "${nomad_binary}"

ACL_DIRECTORY="/ops/shared/config"
CONSUL_BOOTSTRAP_TOKEN="/tmp/consul_bootstrap"
NOMAD_BOOTSTRAP_TOKEN="/tmp/nomad_bootstrap"
NOMAD_USER_TOKEN="/tmp/nomad_user_token"

sed -i "s/CONSUL_TOKEN/${nomad_consul_token_secret}/g" /etc/nomad.d/nomad.hcl

sudo systemctl restart nomad

# Bootstrap consul ACLs
consul acl bootstrap | grep -i secretid | awk '{print $2}' > $CONSUL_BOOTSTRAP_TOKEN

if [ $? -eq 0 ]; then
    consul acl policy create -name 'nomad-auto-join' -rules="@$ACL_DIRECTORY/consul-acl-nomad-auto-join.hcl" -token-file=$CONSUL_BOOTSTRAP_TOKEN

    consul acl role create -name "nomad-auto-join" -description "Role with policies necessary for nomad servers and clients to auto-join via Consul." -policy-name "nomad-auto-join" -token-file=$CONSUL_BOOTSTRAP_TOKEN

    consul acl token create -accessor=${nomad_consul_token_id} -secret=${nomad_consul_token_secret} -description "Nomad server/client auto-join token" -role-name nomad-auto-join -token-file=$CONSUL_BOOTSTRAP_TOKEN

    # Wait for nomad servers to come up
    sleep 30

    # Bootstrap nomad ACLs
    nomad acl bootstrap | grep -i secret | awk -F '=' '{print $2}' | xargs > $NOMAD_BOOTSTRAP_TOKEN

    nomad acl policy apply -token $(cat $NOMAD_BOOTSTRAP_TOKEN) -description "Policy to allow reading of agents and nodes and listing and submitting jobs in all namespaces." node-read-job-submit $ACL_DIRECTORY/nomad-acl-user.hcl

    nomad acl token create -token $(cat $NOMAD_BOOTSTRAP_TOKEN) -name "read-token" -policy node-read-job-submit | grep -i secret | awk -F "=" '{print $2}' | xargs > $NOMAD_USER_TOKEN

    # Write user token to kv
    consul kv put -token-file=$CONSUL_BOOTSTRAP_TOKEN nomad_user_token $(cat $NOMAD_USER_TOKEN)
fi