output "ssh_keys" {
  value = aws_key_pair.ssh.id
}

output "acme_certificate" {
  value = aws_acm_certificate.certificate.*.id
}

output "acme_registration" {
  value = acme_registration.my_registration.id
}

output "letsencrypt" {
  value = acme_certificate.letsencrypt.*.id
}

output "iam_server_certificate" {
  value = aws_iam_server_certificate.my_server_certificate.*.arn
}