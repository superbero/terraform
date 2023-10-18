# resource "aws_key_pair" "myec2key" {
#   key_name = "datascientest_keypair"
#   #public_key = "${file(var.ssh_keys_path)}"
# }

resource "aws_instance" "bastion-host" {
  count                  = length(var.public_subnets_cidrs)
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = element(var.public_subnets_cidrs,count.index)
  #subnet_id              = element(aws_subnet.public_subnets[*].id, count.index)
  vpc_security_group_ids = [var.bastion_web_security_groups_id, var.bastion_ssh_security_groups_id]
  key_name               = var.ssh_keys
  # user_data = <<-EOF
  #           #!/bin/bash
  #           ssh-keygen -t rsa -b 2048 -f ~/.ssh/my_new_key -N ""
  #           echo "Public Key Generated:"
  #           cat ~/.ssh/my_new_key.pub
  #           EOF
  tags = {
    "Name" = "bastion-host_${element(var.available_zones, count.index)}"
  }
}

resource "aws_launch_configuration" "bastion_autoscaling_configuration" {
  image_id      = var.ami
  name          = var.bastion-autoscaling-name
  instance_type = var.instance_type
}
resource "aws_autoscaling_group" "bastion-autoscaling" {
  name                 = "bastion-autoscaling-group"
  max_size             = 2
  min_size             = 1
  desired_capacity     = 1
  launch_configuration = aws_launch_configuration.bastion_autoscaling_configuration.id
  vpc_zone_identifier  = var.public_subnets_cidrs
}

# Creating Wordpress EC2 instance in Private Subnet
resource "aws_instance" "wordpress" {
  count                       = length(var.private_subnets_cidrs)
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.ssh_keys
  # key_name                    = "ssh_keys"
  associate_public_ip_address = true
  security_groups             = [var.webservers_lb_security_group_ids, var.db_servers_security_group_ids]
  #vpc_security_group_ids = [aws_security_group.webservers_lb_sg.id,aws_security_group.db_servers.id]
  subnet_id = element(var.private_subnets_cidrs, count.index)
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y apache2 wget curl php php-mysql mariadb-client
              sudo systemctl enable apache2
              # Remove index.html file
              sudo rm -f /var/www/html/index.html

              sudo wget -c http://wordpress.org/latest.tar.gz -P /var/www/html/
              sudo tar -xzvf /var/www/html/latest.tar.gz -C /var/www/html/
              sudo mv /var/www/html/wordpress/* /var/www/html/
              sudo rm -rf /var/www/html/wordpress
              sudo rm /var/www/html/latest.tar.gz

              # Configure wp-config.php
              sudo mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
              sudo sed -i 's/database_name_here/${aws_db_instance.mariadb-servers[0].db_name}/g' /var/www/html/wp-config.php
              sudo sed -i 's/username_here/${var.db_username}/g' /var/www/html/wp-config.php
              sudo sed -i 's/password_here/${var.db_password}/g' /var/www/html/wp-config.php
              sudo sed -i 's/localhost/${aws_db_instance.mariadb-servers[1].address}/g' /var/www/html/wp-config.php

              # Restart Apache
              sudo systemctl restart apache2

              EOF
  tags = {
    Name = "Wordpress-${element(var.available_zones, count.index)}"
  }
  #depends_on = [aws_lb.webservers_lb]
}

#Create database instances for our different regions
resource "aws_db_instance" "mariadb-servers" {
  count                  = length(var.private_subnets_cidrs)
  identifier             = "mariadb-${element(var.available_zones, count.index)}"
  skip_final_snapshot    = true
  allocated_storage      = 10
  engine                 = "mariadb"
  instance_class         = "db.${var.instance_type}"
  db_name                = "wordpress_db"
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = element(var.db_subnet_group_ids, count.index)
  #vpc_security_group_ids = var.db_subnet_group_ids
  vpc_security_group_ids = [var.db_servers_security_group_ids]

  tags = {
    "Name" = "MariaDB-server_${element(var.available_zones, count.index)}"
  }
}

output "db_servers_ip" {
  value = aws_db_instance.mariadb-servers[0].address
}


# create the template for the autoscaling group
# resource "aws_launch_template" "autoscaling_template" {
#   vpc_security_group_ids = [ for sg in aws_security_group.webservers_lb_sg[*]: sg.id]
#   name = var.available_zones[1]

#   image_id = var.ami
#   ebs_optimized = true
#   monitoring {
#     enabled = true
#   }

#   instance_type = "t2.micro"

#   tags = {
#     Name = "Wordpress-autoscaling"
#   }
#   placement {
#     availability_zone = "eu-west-3b"
#   }
# }

resource "aws_launch_configuration" "webservers_autoscaling_configuration" {
  image_id      = var.ami
  name          = "webservers-autoscaling-config"
  instance_type = var.instance_type
}

#Create an autoscaling group for webservers
resource "aws_autoscaling_group" "webservers-autoscaling" {
  name                 = "webservers-autoscaling-group"
  max_size             = 2
  min_size             = 1
  desired_capacity     = 1
  launch_configuration = aws_launch_configuration.webservers_autoscaling_configuration.id
  vpc_zone_identifier  = var.private_subnets_cidrs
  # launch_template {
  #   id = aws_launch_template.autoscaling_template.id
  #   version = "$Latest"
  # }
}