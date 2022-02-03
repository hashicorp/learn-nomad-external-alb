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
terraform init
terraform apply \
-var="nomad_consul_token_id=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXXXX" \
-var="nomad_consul_token_secret=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXXXX"
```

4. Run `post-setup.sh` to retrieve the Nomad ACL token, write it to a local file, and delete it from the Consul KV store.
```
./post-setup.sh

The Nomad user token has been saved locally to nomad.token and deleted from the Consul KV store

Set the following environment variables to access your Nomad cluster with the user token created during setup:

export NOMAD_ADDR=http://nomad-server-lb-XXXXXXXXXX.us-east-1.elb.amazonaws.com:4646
export NOMAD_TOKEN=$(cat nomad.token)
```

5. Export the Nomad environment variables using the commands from the output in step 4 and test connectivity to the cluster.
```
export NOMAD_ADDR=http://nomad-server-lb-XXXXXXXXXX.us-east-1.elb.amazonaws.com:4646
export NOMAD_TOKEN=$(cat nomad.token)

nomad node status
```

6. Run the demo webapp and nginx proxy jobs.
```
nomad job run nomad/webapp.nomad
nomad job run nomad/nginx.nomad
```

7. Uncomment the code in [aws/env/us-east/`alb.tf`](aws/env/us-east/alb.tf) and apply it with Terraform.
```
terraform apply
...
alb_address = "http://nomad-ingress-alb-XXXXXXXXX.us-east-1.elb.amazonaws.com:80"
```

8. View the demo webapp by visiting the `alb_address` in the terraform output from the previous step. Refresh the page to see that requests get sent to different nodes.