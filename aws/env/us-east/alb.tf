data "aws_vpc" "default" {
  default = true
}

resource "aws_lb" "nomad_clients_ingress" {
  name               = "nomad-ingress-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.hashistack.clients_ingress_sg.id]
//   subnets            = [for subnet in aws_subnet.public : subnet.id]
# TODO: Get subnets somehow...
  subnets            = ["subnet-632ae242","subnet-b9a13cf4"]
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
  target_group_arn = aws_lb_target_group.nomad_clients.arn
  # TODO: Update target to iterate over list
  target_id        = module.hashistack.nomad_clients[0].id
  port             = 8080
//   count            = var.client_count
}

output "alb_address" {
    value = "http://${aws_lb.nomad_clients_ingress.dns_name}:80"
}