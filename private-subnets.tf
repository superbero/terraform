resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnets_cidrs)
  vpc_id            = aws_vpc.vpc.id # attached to vpc
  cidr_block        = element(var.private_subnets_cidrs, count.index)
  availability_zone = element(var.available_zones, count.index)
  #map_public_ip_on_launch = true
  tags = {
    Name = "Onesime-Private subnet_${element(var.available_zones, count.index)}"
  }
}
# create an elastic ip from each public subnet ip
resource "aws_eip" "elastic_ip" {
  #vpc = true
  count                     = length(var.public_subnets_cidrs)
  associate_with_private_ip = element(var.public_subnets_cidrs, count.index)
  tags = {
    Name = "Elastic IPs on public subnets_${element(var.available_zones, count.index)}"
  }
}
# resource "aws_route_table" "rtb_private" {
#   vpc_id = aws_vpc.vpc.id
#   count = length(var.private_subnets_cidrs)
#   route {
#     cidr_block = "0.0.0.0/0"
#     nat_gateway_id = element(aws_nat_gateway.nat-gateway[*].id,count.index)
#   }
#   tags = {
#     Name = "Onesime_RTB-private_${element(var.available_zones,count.index)}"
#   }
# }

resource "aws_route_table_association" "rtb_private_subnets_association" {
  count          = length(var.private_subnets_cidrs)
  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
  route_table_id = element(aws_route_table.rtb_public[*].id, count.index)
  depends_on     = [aws_eip.elastic_ip]
}

resource "aws_db_subnet_group" "my_private_subnet_group" {
  name       = "my-private-db-subnet-group"
  subnet_ids = [for subnet in aws_subnet.private_subnets : subnet.id] # Assuming you have one private subnet
}