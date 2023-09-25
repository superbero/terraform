# resource "aws_key_pair" "myec2key" {
#   key_name = "datascientest_keypair"
#   #public_key = "${file(var.ssh_keys_path)}"
# }

resource "aws_instance" "bastion-host" {
  count                  = length(var.public_subnets_cidrs)
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = element(aws_subnet.public_subnets[*].id, count.index)
  vpc_security_group_ids = [aws_security_group.allow_ssh_bastion.id, aws_security_group.allow_https_bastion.id]
  key_name               = aws_key_pair.ssh.id
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
  name          = "bastion-autoscaling-config"
  instance_type = var.instance_type
}
resource "aws_autoscaling_group" "bastion-autoscaling" {
  name                 = "bastion-autoscaling-group"
  max_size             = 2
  min_size             = 1
  desired_capacity     = 1
  launch_configuration = aws_launch_configuration.bastion_autoscaling_configuration.id
  vpc_zone_identifier  = [aws_subnet.public_subnets[0].id, aws_subnet.public_subnets[1].id]
  # launch_template {
  #   id = aws_launch_template.autoscaling_template.id
  #   version = "$Latest"
  # }
}

output "bastion_public_ip" {
  value = aws_instance.bastion-host[0].public_ip
}

