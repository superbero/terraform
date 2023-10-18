variable "ami" {
  type = string
}

variable "public_subnets_cidrs" {
  type = list(string)
}

variable "private_subnets_cidrs" {
  type = list(string)
}

variable "available_zones" {
  type = list(string)
}

variable "instance_type" {
  type = string
}

variable "db_password" {
  type = string
}

variable "db_username" {
  type = string
}

variable "bastion-autoscaling-name" {
  default = "bastion-autoscaling-config"
}

variable "bastion_web_security_groups_id" {
  type = string
}

variable "bastion_ssh_security_groups_id" {
  type = string
}

variable "db_servers_security_group_ids" {
  type = string
}

variable "webservers_lb_security_group_ids" {
  type = string
}

variable "db_subnet_group_ids" {
  type = list(string)
}

variable "ssh_keys" {
  type = string
}