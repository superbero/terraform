output "sg-bastion_ssh" {
  value = aws_security_group.allow_ssh_bastion.id
}

output "sg-bastion-web" {
  value = aws_security_group.allow_https_bastion.id
}

output "sg-webservers" {
  value = aws_security_group.webservers_lb_sg.id
}

output "sg-db_servers" {
  value = aws_security_group.db_servers.id
}