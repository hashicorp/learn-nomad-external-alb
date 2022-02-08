data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default_subnets" {
    vpc_id = data.aws_vpc.default.id
}

resource "aws_lb" "nomad_clients_ingress" {
  name               = "nomad-ingress-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.hashistack.clients_ingress_sg.id]
  subnets            = data.aws_subnet_ids.default_subnets.ids
}

resource "aws_lb_listener" "nomad_listener" {
  load_balancer_arn = aws_lb.nomad_clients_ingress.id
  port              = 80

  default_action {
    target_group_arn = aws_lb_target_group.nomad_clients.id
    type             = "forward"
  }
}

resource "aws_lb_target_group" "nomad_clients" {
  name     = "nomad-clients"
  # App listener port, change for HashiCups
  port     = 8080 
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    port = 8080
    path = "/"
    # Mark healthy if redirected
    matcher = "200,301,302"
  }
}

resource "aws_lb_target_group_attachment" "nomad_clients" {
  count = var.client_count
  target_group_arn = aws_lb_target_group.nomad_clients.arn
  target_id = element(split(",", module.hashistack.nomad_clients_ids), count.index)
  # Assign only targeted clients to ALB
  // target_id = element(split(",", module.hashistack.targeted_nomad_clients_ids), count.index)
  port             = 8080
}

output "alb_address" {
    value = "http://${aws_lb.nomad_clients_ingress.dns_name}:80"
}