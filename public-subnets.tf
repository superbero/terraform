#Create all public subnets in different zones
resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnets_cidrs)
  vpc_id                  = aws_vpc.vpc.id # attached to vpc
  cidr_block              = element(var.public_subnets_cidrs, count.index)
  availability_zone       = element(var.available_zones, count.index)
  map_public_ip_on_launch = true
  depends_on              = [aws_vpc.vpc]
  tags = {
    Name = "Onesime-Public subnet_${element(var.available_zones, count.index)}"
  }
}

# create route for the main vpc and attach Internet Gateway 

resource "aws_route_table" "rtb_public" {
  vpc_id = aws_vpc.vpc.id
  count  = length(var.public_subnets_cidrs)
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-public_subnets.id
  }
  route {
    cidr_block     = element(aws_subnet.public_subnets[*].cidr_block, count.index)
    nat_gateway_id = element(aws_nat_gateway.nat-gateway[*].id, count.index)
  }
  tags = {
    Name = "Onesime-rtb_public ${element(var.available_zones, count.index)}"
  }

}

resource "aws_route_table_association" "rtb_public_subnets_association" {
  count          = length(var.public_subnets_cidrs)
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = element(aws_route_table.rtb_public[*].id, count.index)
  depends_on     = [aws_internet_gateway.igw-public_subnets]
}