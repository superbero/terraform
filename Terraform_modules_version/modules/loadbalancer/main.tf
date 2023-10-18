resource "aws_lb" "webservers_lb" {
  count              = length(var.private_subnets_cidrs)
  name               = "webservers-lb-${element(var.available_zones, count.index)}"
  internal           = false
  load_balancer_type = var.loadbalancer-type
  security_groups    = [var.webservers_lb_security_group_ids]
  #security_groups    = [aws_security_group.webservers_lb_sg.id]
  #subnets            = [for subnet in aws_subnet.private_subnets : subnet.id]
  subnets           = var.private_subnets_cidrs

  enable_deletion_protection = false

  tags = {
    Name = "webservers_lb-${element(var.available_zones, count.index)}"
  }
}

resource "aws_lb_listener" "webservers_lb_listener" {
  count             = length(var.private_subnets_cidrs)
  load_balancer_arn = element(aws_lb.webservers_lb[*].arn, count.index)
  port              = var.http_port
  protocol          = var.protocol
  default_action {
    type             = "forward"
    target_group_arn = element(aws_lb_target_group.webservers_vms[*].arn, count.index)
  }
}

#add listener for port 443
resource "aws_lb_listener" "webservers_https_listener" {
  count             = 2
  load_balancer_arn = element(aws_lb.webservers_lb[*].arn, count.index)
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = element(var.iam_server_certificate, count.index)

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_target_group" "webservers_vms" {
  count    = length(var.private_subnets_cidrs)
  name     = "webservers-lb-tg-${element(var.available_zones, count.index)}"
  vpc_id   = var.vpc_id
  protocol = var.protocol
  port     = var.http_port
}

resource "aws_lb_target_group_attachment" "webservers_vms_association" {
  count            = length(var.private_subnets_cidrs)
  target_group_arn = element(aws_lb_target_group.webservers_vms[*].arn, count.index)
  target_id        = element(var.webservers_id, count.index)

  port = 80
}

#Create a new ALB target group attachment
resource "aws_autoscaling_attachment" "lb_webservers-autoscaling_association" {
  count                  = length(var.private_subnets_cidrs)
  autoscaling_group_name = var.webservers_autoscaling_id
  #lb_target_group_arn = element(var.webservers_vms_arn,count.index)
  lb_target_group_arn    = element(aws_lb_target_group.webservers_vms[*].arn, count.index)
}

output "load_balancer_dns_name" {
  value = aws_lb.webservers_lb[0].dns_name
}