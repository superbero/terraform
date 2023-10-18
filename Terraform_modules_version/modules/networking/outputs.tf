output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnets_ids" {
  value = aws_subnet.public_subnets.*.id
}

output "private_subnets_cidrs" {
  value = aws_subnet.private_subnets.*.cidr_block
}

output "private_subnets_ids" {
  value = aws_subnet.private_subnets.*.id
}

output "db_subnet_group_ids" {
  value = aws_db_subnet_group.my_private_subnet_group.*.id
}

output "public_subnets_ign_ids" {
  value = aws_internet_gateway.igw-public_subnets.*.id
}