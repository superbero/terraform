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
  region = var.region
  #   secret_key = var.secret_key
  #   access_key = var.access_key Terraform_modules_version/aws/config
  shared_credentials_files = ["./aws/credentials"]
  shared_config_files      = ["./aws/aws/config"]
}

provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

provider "tls" {
}



module "networking" {
  source                = "./modules/networking"
  vpc                   = var.vpc
  available_zones       = var.available_zones
  public_subnets_cidrs  = var.public_subnets_cidrs
  private_subnets_cidrs = var.private_subnets_cidrs
  annotations           = var.annotations
  ssh_keys_path         = var.ssh_keys_path
}

module "security" {
  source               = "./modules/security"
  vpc_id               = module.networking.vpc_id
  public_subnets_cidrs = module.networking.public_subnets_ids
  #private_subnets_cidrs = module.networking.private_subnets_ids
  private_subnets_cidrs_id = module.networking.private_subnets_cidrs
}

module "instances" {
  source                           = "./modules/instances"
  private_subnets_cidrs            = module.networking.private_subnets_ids
  public_subnets_cidrs             = module.networking.public_subnets_ids
  bastion_web_security_groups_id   = module.security.sg-bastion-web
  bastion_ssh_security_groups_id   = module.security.sg-bastion_ssh
  db_subnet_group_ids              = module.networking.db_subnet_group_ids
  db_servers_security_group_ids    = module.security.sg-db_servers
  webservers_lb_security_group_ids = module.security.sg-webservers
  available_zones                  = var.available_zones
  db_password                      = var.db_password
  db_username                      = var.db_username
  ami                              = var.ami
  instance_type                    = var.instance_type
  ssh_keys                         = module.certificates.ssh_keys
}

module "loadbalancer" {
  source                           = "./modules/loadbalancer"
  vpc_id                           = module.networking.vpc_id
  private_subnets_cidrs            = module.networking.public_subnets_ids
  available_zones                  = var.available_zones
  webservers_lb_security_group_ids = module.security.sg-webservers
  webservers_id                    = module.instances.webservers_ids
  webservers_autoscaling_id        = module.instances.webservers-autoscaling_ids
  #webservers_vms_arn               = module.instances.webservers_ids
  iam_server_certificate = module.certificates.iam_server_certificate
}

module "certificates" {
  source                  = "./modules/certificates"
  webservers-loadbalancer = module.loadbalancer.loadbalancer-webservers
}


