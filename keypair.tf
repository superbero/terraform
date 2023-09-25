resource "aws_key_pair" "ssh" {
  key_name   = "ssh_keys"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "ssh_keys" {
  content         = tls_private_key.rsa.private_key_pem
  file_permission = 400
  filename        = "connect_to_bastion.pem"
}

resource "tls_private_key" "my_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "acme_registration" "my_registration" {
  account_key_pem = tls_private_key.my_private_key.private_key_pem
  email_address   = "onesimeking@gmail.com"
}
# Generating a tls private key to use for my certificate for the TLS
resource "acme_certificate" "letsencrypt" {
  count           = length(aws_lb.webservers_lb)
  account_key_pem = tls_private_key.my_private_key.private_key_pem
  common_name     = "terraform.delavant.cloudns.ph"
  tls_challenge {

  }
  http_challenge {
    port = 80
  }
}

resource "aws_iam_server_certificate" "my_server_certificate" {
  count             = 2
  name              = "my-server-certificate"
  certificate_body  = element(acme_certificate.letsencrypt[*].certificate_pem, count.index)
  private_key       = tls_private_key.my_private_key.private_key_pem
  certificate_chain = element(acme_certificate.letsencrypt[*].preferred_chain, count.index)
}

#store this certification in certificate list
resource "aws_acm_certificate" "certificate" {
  count             = 2
  certificate_body  = element(acme_certificate.letsencrypt[*].certificate_pem, count.index)
  private_key       = element(acme_certificate.letsencrypt[*].private_key_pem, count.index)
  certificate_chain = element(acme_certificate.letsencrypt[*].issuer_pem, count.index)
}