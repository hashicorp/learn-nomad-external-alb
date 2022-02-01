// data "aws_vpc" "default" {
//   default = true
// }

// resource "aws_lb" "nomad_ingress" {
//   name               = "nomad-ingress-alb"
//   internal           = false
//   load_balancer_type = "application"
//   security_groups    = [module.hashistack.sec_group_server_lb.id]
// //   subnets            = [for subnet in data.aws_vpc.default.subnets : subnet]
// }

// resource "aws_lb_listener" "nomad_listener" {
//   load_balancer_arn = aws_lb.nomad_ingress.id
//   port              = 80

//   default_action {
//     target_group_arn = aws_lb_target_group.nomad.id
//     type             = "forward"
//   }
// }

// resource "aws_lb_target_group" "nomad" {
//   name     = "nomad-servers"
//   # App listener port, change for HashiCups
//   port     = 4646 
//   protocol = "HTTP"
//   vpc_id   = data.aws_vpc.default.id

//   health_check {
//     port = 4646
//     path = "/ui"
//     # Mark healthy if redirected
//     matcher = "200,301,302"
//   }
// }

// resource "aws_lb_target_group_attachment" "nomad" {
//   target_group_arn = aws_lb_target_group.nomad.arn
//   # TODO: Update target to iterate over list
//   target_id        = module.hashistack.servers_list[0].id
//   port             = 4646
// }

// // resource "aws_lb_listener" "consul_listener" {
// //   load_balancer_arn = aws_lb.nomad_ingress.id
// //   port              = 8080

// //   default_action {
// //     target_group_arn = aws_lb_target_group.consul.id
// //     type             = "forward"
// //   }
// // }

// // resource "aws_lb_target_group" "consul" {
// //   name     = "consul-service"
// //   port     = 8500 
// //   protocol = "HTTP"
// //   vpc_id   = data.aws_vpc.default.id

// //   health_check {
// //     port = 8500
// //     path = "/ui"
// //     # Mark healthy if redirected
// //     matcher = "200,301,302"
// //   }
// // }

// // resource "aws_lb_target_group_attachment" "consul" {
// //   target_group_arn = aws_lb_target_group.consul.arn
// //   target_id        = aws_instance.server[0].id
// //   port             = 8500
// // }