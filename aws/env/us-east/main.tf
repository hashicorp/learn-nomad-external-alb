provider "aws" {
  region = var.region
}

module "hashistack" {
  source = "../../modules/hashistack"

  name                   = var.name
  region                 = var.region
  ami                    = var.ami
  server_instance_type   = var.server_instance_type
  client_instance_type   = var.client_instance_type
  targetted_client_instance_type = var.targetted_client_instance_type
  targetted_client_count = var.targetted_client_count
  key_name               = var.key_name
  server_count           = var.server_count
  client_count           = var.client_count
  retry_join             = var.retry_join
  nomad_binary           = var.nomad_binary
  nomad_consul_token_id  = var.nomad_consul_token_id
  nomad_consul_token_secret = var.nomad_consul_token_secret
  root_block_device_size = var.root_block_device_size
  whitelist_ip           = var.whitelist_ip
}
