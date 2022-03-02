output "lb_address_consul_nomad" {
  value = "http://${aws_elb.server_lb.dns_name}"
}

output "consul_bootstrap_token_secret" {
  value = var.nomad_consul_token_secret
}

output "IP_Addresses" {
  value = <<CONFIGURATION

Client public IPs: ${join(", ", aws_instance.client[*].public_ip)}

Targeted client public IPs: ${join(", ", aws_instance.targeted_client[*].public_ip)}

Server public IPs: ${join(", ", aws_instance.server[*].public_ip)}

The Consul UI can be accessed at http://${aws_elb.server_lb.dns_name}:8500/ui
with the bootstrap token: ${var.nomad_consul_token_secret}
CONFIGURATION
}