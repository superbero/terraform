variable "ssh_port" {
  default = 22
  description = "ssh port value"
}

variable "ssh_tags" {
  default = "allow_ssh_on_ec2"
}

variable "http_port" {
    default = 80
    description = "http protocol port"
}

variable "https_port" {
  default = 443
  description = "https protocol port"
}

variable "tcp" {
  default = "tcp"
}

variable "cidr_blocks" {
    default = ["0.0.0.0/0"]
    type = list(string)
    description = "ip address to use for the security groups"
}
variable "db_servers_port" {
    default = 3306
    description = "Ingress port for the database servers"
}

variable "db_servers_tags" {
  default = "database-sg-mysql"
}

variable "loadbalancer_name" {
  default = "loadbalancer-sg"
}

variable "vpc_id" {
  type = string
}

variable "public_subnets_cidrs" {
  type = list(string)
}

variable "private_subnets_cidrs_id" {
  type = list(string)
}