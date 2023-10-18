variable "server_url" {
  default = "https://acme-v02.api.letsencrypt.org/directory"
}

variable "email_address" {
  default = "onesimeking@gmail.com"
}

variable "web_url" {
  default = "terraform.delavant.cloudns.ph"
}

variable "webservers-loadbalancer" {
  type = list(string)
}

variable "region" {
  default = "eu-west-3"
}