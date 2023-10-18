resource "aws_vpc" "vpc" {
  cidr_block = var.vpc

  tags = {
    Name = "Onesime-VPC"
  }
}

# define the public subnets
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
# create route table association for public subnets to the the nat gateway
resource "aws_route_table_association" "rtb_public_subnets_association" {
  count          = length(var.public_subnets_cidrs)
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = element(aws_route_table.rtb_public[*].id, count.index)
  depends_on     = [aws_internet_gateway.igw-public_subnets]
}

# create the internet gateway for the public subnets
resource "aws_internet_gateway" "igw-public_subnets" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "Onesime-Public_subnets_IGW"
  }
}

# create the nat gateway for the public subnets with elastic ip
resource "aws_nat_gateway" "nat-gateway" {
  count         = length(var.public_subnets_cidrs)
  allocation_id = element(aws_eip.elastic_ip[*].id, count.index)
  subnet_id     = element(aws_subnet.public_subnets[*].id, count.index)

  tags = {
    Name = "Onesime_NAT-${element(var.available_zones, count.index)}"
  }
}

# Define the private subnets to the main VPC
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

# create route table association for private subnets 
resource "aws_route_table_association" "rtb_private_subnets_association" {
  count          = length(var.private_subnets_cidrs)
  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
  route_table_id = element(aws_route_table.rtb_public[*].id, count.index)
  depends_on     = [aws_eip.elastic_ip]
}

# create a database subnet group 
resource "aws_db_subnet_group" "my_private_subnet_group" {
  name       = "my-private-db-subnet-group"
  subnet_ids = [for subnet in aws_subnet.private_subnets : subnet.id] # Assuming you have one private subnet
}