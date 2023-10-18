output "bastion_public_ip" {
  value = aws_instance.bastion-host[0].public_ip
}

output "wordpress_public_ip_a" {
  value = aws_instance.wordpress[0].public_ip
}
output "wordpress_public_ip_b" {
  value = aws_instance.wordpress[1].public_ip
}

output "bastion-hosts" {
  value = aws_instance.bastion-host.*.id
}

output "webservers_ids" {
  value = aws_instance.wordpress.*.id
}

output "webservers-autoscaling_ids" {
  value = aws_autoscaling_group.webservers-autoscaling.id
}
