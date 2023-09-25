terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">5.0"
    }
    acme = {
      source  = "vancluever/acme"
      version = "~> 2.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~>4.0"
    }
  }
}

provider "aws" {
  region     = var.region
#   secret_key = var.secret_key
#   access_key = var.access_key
  shared_credentials_files = ["./aws/credentials"]
  shared_config_files      = ["./aws/aws/config"]
}

provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

provider "tls" {
}