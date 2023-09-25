resource "aws_security_group" "allow_ssh_bastion" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic and outbound traffic to port 22"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow Bastion SSH from remote machine"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # egress {
  #   description = "Denied Bastion SSH connection to remote machine"
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  tags = {
    Name = "allow_ssh_on_ec2"
  }
}

resource "aws_security_group" "allow_https_bastion" {
  vpc_id = aws_vpc.vpc.id
  name   = "allow_http"

  ingress {
    description = "Allow HTTP on Bastion"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS on Bastion"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound connection from port 80 on Bastion"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound connection from port 443 on Bastion"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound on all the ports on bastion server"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "webservers_lb_sg" {
  name   = "loadbalancer-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "Allow inbound traffic on port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow inbound traffic on port 443"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow inbound traffic on port 22 for ssh connection"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    description = "Allow outbound connection from port 80 on Loadbalancer"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound connection from port 443 on Loadbalancer"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound on all the ports on bastion server"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "db_servers" {
  vpc_id = aws_vpc.vpc.id
  name   = "database server security group"

  ingress {
    description = "Allow connections to mysql databases server"
    from_port   = 3306
    to_port     = 3306
    protocol    = "TCP"
    cidr_blocks = [for subnet in aws_subnet.private_subnets : subnet.cidr_block]
  }
  # egress {
  #   from_port   = 0
  #   to_port     = 65535
  #   protocol    = "tcp"
  #   cidr_blocks = [for subnet in aws_subnet.private_subnets : subnet.cidr_block]
  # }
  tags = {
    Name = "database-sg-mysql"
  }
}

# resource "aws_security_group_rule" "db_servers_rules" {

#   type = "ingress"
#   from_port = 
# }
