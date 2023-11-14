variable "region" {
  type    = string
  default = "eu-west-3"
}

variable "vpc" {
  type        = string
  default     = "172.16.0.0/16"
  description = "main vpc"
}

variable "public_subnets_cidrs" {
  type    = list(string)
  default = ["172.16.1.0/24", "172.16.2.0/24"]
}

variable "private_subnets_cidrs" {
  type    = list(string)
  default = ["172.16.10.0/24", "172.16.20.0/24"]
}

variable "available_zones" {
  type    = list(string)
  default = ["eu-west-3a", "eu-west-3b"]
}

variable "annotations" {
  type    = list(string)
  default = ["a", "b"]
}

variable "ssh_keys_path" {
  default = "./ssh _keys"
}

variable "ami" {
  default = "ami-05b5a865c3579bbc4"
}

variable "db_username" {
  description = "wordpress db username"
  default     = "wordpress"
}

variable "db_password" {
  description = "wordpress db password"
  default     = "b25lc2ltZQo="
}

variable "instance_type" {
  description = "value for the instance type"
  default     = "t3.micro"

}
