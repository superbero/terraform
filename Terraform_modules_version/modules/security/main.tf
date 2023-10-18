resource "aws_security_group" "allow_ssh_bastion" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic and outbound traffic to port var.ssh_port"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow Bastion SSH from remote machine"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = var.tcp
    cidr_blocks = var.cidr_blocks
  }

  # egress {
  #   description = "Denied Bastion SSH connection to remote machine"
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = var.tcp
  #   cidr_blocks = var.cidr_blocks
  # }

  tags = {
    Name = var.ssh_tags
  }
}

resource "aws_security_group" "allow_https_bastion" {
  vpc_id = var.vpc_id   #var.vpc_id #aws_vpc.vpc.id
  name   = "allow_http"

  ingress {
    description = "Allow HTTP on Bastion"
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = var.tcp
    cidr_blocks = var.cidr_blocks
  }

  ingress {
    description = "Allow HTTPS on Bastion"
    from_port   = var.https_port
    to_port     = var.https_port
    protocol    = var.tcp
    cidr_blocks = var.cidr_blocks
  }

  egress {
    description = "Allow outbound connection from port var.http_port on Bastion"
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = var.tcp
    cidr_blocks = var.cidr_blocks
  }

  egress {
    description = "Allow outbound connection from port var.https_port on Bastion"
    from_port   = var.https_port
    to_port     = var.https_port
    protocol    = var.tcp
    cidr_blocks = var.cidr_blocks
  }

  egress {
    description = "Allow outbound on all the ports on bastion server"
    from_port   = 0
    to_port     = 65535
    protocol    = var.tcp
    cidr_blocks = var.cidr_blocks
  }
}

resource "aws_security_group" "webservers_lb_sg" {
  name   = var.loadbalancer_name
  vpc_id = var.vpc_id #aws_vpc.vpc.id

  ingress {
    description = "Allow inbound traffic on port 80 var.http_port"
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = var.tcp
    cidr_blocks = var.cidr_blocks
  }

  ingress {
    description = "Allow inbound traffic on port var.https_port"
    from_port   = var.https_port
    to_port     = var.https_port
    protocol    = var.tcp
    cidr_blocks = var.cidr_blocks
  }

  ingress {
    description = "Allow inbound traffic on port var.ssh_port for ssh connection"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = var.tcp
    cidr_blocks = var.cidr_blocks
  }


  egress {
    description = "Allow outbound connection from port var.http_port on Loadbalancer"
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = var.tcp
    cidr_blocks = var.cidr_blocks
  }

  egress {
    description = "Allow outbound connection from port var.https_port on Loadbalancer"
    from_port   = var.https_port
    to_port     = var.https_port
    protocol    = var.tcp
    cidr_blocks = var.cidr_blocks
  }

  egress {
    description = "Allow outbound on all the ports on bastion server"
    from_port   = 0
    to_port     = 65535
    protocol    = var.tcp
    cidr_blocks = var.cidr_blocks
  }
}

resource "aws_security_group" "db_servers" {
  vpc_id = var.vpc_id #aws_vpc.vpc.id
  name   = "database server security group"

  ingress {
    description = "Allow connections to mysql databases server"
    from_port   = var.db_servers_port
    to_port     = var.db_servers_port
    protocol    = var.tcp
    #cidr_blocks = [for subnet in aws_subnet.private_subnets : subnet.cidr_block]
    cidr_blocks = var.private_subnets_cidrs_id
  }
  
  tags = {
    Name = var.db_servers_tags
  }
}

