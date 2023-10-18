variable "vpc_id" {
 type = string
}

variable "http_port" {
  default = 80
}
variable "protocol" {
  default = "HTTP"
}

variable "private_subnets_cidrs" {
  type = list(string)
}

variable "available_zones" {
  type = list(string)
}

variable "loadbalancer-type" {
  default = "application"
}

variable "webservers_lb_security_group_ids" {
  type = string
}

variable "webservers_id" {
  type = list(string)
}

variable "webservers_autoscaling_id" {
  type = string
}

variable "iam_server_certificate" {
  type = list(string)
}

