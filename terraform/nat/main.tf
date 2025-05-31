resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = var.public_subnet_id # 172.16.1.0/24 (ap-northeast-2c)
  tags = {
    Name = "${var.name_prefix}-nat"
  }
}

resource "aws_route_table" "private" {
  vpc_id = var.vpc_id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
}

# private_c만 NAT 라우팅
resource "aws_route_table_association" "private_c" {
  subnet_id      = var.private_c_id # 172.16.11.0/24
  route_table_id = aws_route_table.private.id
} 