resource "aws_internet_gateway" "igw-public_subnets" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "Onesime-Public_subnets_IGW"
  }
}

resource "aws_nat_gateway" "nat-gateway" {
  count         = length(var.public_subnets_cidrs)
  allocation_id = element(aws_eip.elastic_ip[*].id, count.index)
  subnet_id     = element(aws_subnet.public_subnets[*].id, count.index)

  tags = {
    Name = "Onesime_NAT-${element(var.available_zones, count.index)}"
  }
}