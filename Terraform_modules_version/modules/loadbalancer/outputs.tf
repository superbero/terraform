output "loadbalancer-webservers" {
  value = aws_lb.webservers_lb.*.id
}

output "loadbalancer-webservers-http-listener" {
  value = aws_lb_listener.webservers_lb_listener.*.arn
}

output "loadbalancer-webservers_https_listener" {
  value = aws_lb_listener.webservers_https_listener.*.arn
}

output "loadbalancer-webservers-vms" {
  value = aws_lb_target_group.webservers_vms.*.arn
}

