variable "vpc" {
  type    = string
}

variable "public_subnets_cidrs" {
  type    = list(string)
}

variable "private_subnets_cidrs" {
  type    = list(string)
}

variable "available_zones" {
  type    = list(string)
}

variable "annotations" {
  type    = list(string)
}

variable "ssh_keys_path" {
  type = string
}