data "aws_subnet_ids" "default_subnets" {
    vpc_id = data.aws_vpc.default.id
}

resource "aws_lb" "nomad_clients_ingress" {
  name               = "nomad-ingress-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.clients_ingress_sg.id]
  subnets            = data.aws_subnet_ids.default_subnets.ids
}

resource "aws_lb_listener" "nomad_listener" {
  load_balancer_arn = aws_lb.nomad_clients_ingress.id
  port              = 80

  default_action {
    type             = "forward"
    
    forward {
      target_group {
        arn = aws_lb_target_group.nomad_clients.arn
      }
      target_group {
        arn = aws_lb_target_group.nomad_clients_targeted.arn
      }
    }
  }
}

# nomad clients in dc1
resource "aws_lb_target_group" "nomad_clients" {
  name     = "nomad-clients"
  # App listener port
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
  target_id = element(split(",", join(",", aws_instance.client.*.id)), count.index)
  port             = 8080
}

resource "aws_lb_listener_rule" "nomad_clients" {
  listener_arn = aws_lb_listener.nomad_listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nomad_clients.arn
  }

  condition {
    path_pattern {
      values = ["/dc1"]
    }
  }
}

# nomad clients in dc2
resource "aws_lb_target_group" "nomad_clients_targeted" {
  name     = "nomad-clients-targeted"
  # App listener port
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

resource "aws_lb_target_group_attachment" "nomad_clients_targeted" {
  count = var.targeted_client_count
  target_group_arn = aws_lb_target_group.nomad_clients_targeted.arn
  target_id = element(split(",", join(",", aws_instance.targeted_client.*.id)), count.index)
  port             = 8080
}

resource "aws_lb_listener_rule" "nomad_clients_targeted" {
  listener_arn = aws_lb_listener.nomad_listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nomad_clients_targeted.arn
  }

  condition {
    path_pattern {
      values = ["/dc2"]
    }
  }
}

output "alb_address" {
    value = "http://${aws_lb.nomad_clients_ingress.dns_name}:80"
}