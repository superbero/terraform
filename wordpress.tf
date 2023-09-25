# Creating Wordpress EC2 instance in Private Subnet
resource "aws_instance" "wordpress" {
  count                       = length(var.private_subnets_cidrs)
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = "ssh_keys"
  associate_public_ip_address = true
  security_groups             = [aws_security_group.webservers_lb_sg.id, aws_security_group.db_servers.id]
  #vpc_security_group_ids = [aws_security_group.webservers_lb_sg.id,aws_security_group.db_servers.id]
  subnet_id = element(aws_subnet.private_subnets[*].id, count.index)
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
  depends_on = [aws_lb.webservers_lb]
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
  db_subnet_group_name   = element(aws_db_subnet_group.my_private_subnet_group[*].id, count.index)
  vpc_security_group_ids = [aws_security_group.db_servers.id]

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
  vpc_zone_identifier  = [aws_subnet.private_subnets[0].id, aws_subnet.private_subnets[1].id]
  # launch_template {
  #   id = aws_launch_template.autoscaling_template.id
  #   version = "$Latest"
  # }
}




output "wordpress_public_ip_a" {
  value = aws_instance.wordpress[0].public_ip
}
output "wordpress_public_ip_b" {
  value = aws_instance.wordpress[1].public_ip
}