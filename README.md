# Nomad External Ingress with AWS ALB

## Bootstrap Nomad cluster with Consul
- Leverages Terraform code from the [Nomad repository](https://github.com/hashicorp/nomad/tree/main/terraform) to provision a cluster on AWS with Consul
- Enables ACLs for both Consul and Nomad

## Usage
1. Build AMI with Packer
```
cd aws
packer build packer.json
```

2. Update these values in [terraform.tfvars](aws/env/us-east/terraform.tfvars) as necessary (make sure to use your AWS keypair):  
`key_name`  
`ami` (output from previous step)  
`server_instance_type`  
`server_count`  
`client_instance_type`  
`client_count`

3. Run `terraform apply` with token id and secret values to create the cluster
```
cd aws/env/us-east
terraform apply \
-var="nomad_consul_token_id=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXXXX" \
-var="nomad_consul_token_secret=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXXXX"
```

4. Run `post-setup.sh` to retrieve the Nomad ACL token from Consul KV (temporary).
```
./post-setup.sh

Set the following environment variables to access your Nomad cluster with the user token created during setup:

export NOMAD_ADDR=http://nomad-server-lb-XXXXXXXXXX.us-east-1.elb.amazonaws.com:4646
export NOMAD_TOKEN=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXXXX