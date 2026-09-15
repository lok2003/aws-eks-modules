resource "aws_vpc" "eks_vpc" {
  cidr_block = var.vpc.cidr_block
  tags = {
    Name = var.vpc.name
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = {
    Name = "IGW"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = {
    Name = "eks-public-route"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.eks_vpc.id
  tags = {
    Name = "eks-private-route"
  }
}

resource "aws_route" "igw_route" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnet)
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = var.public_subnet[count.index].cidr_block
  availability_zone       = var.public_subnet[count.index].availability_zone
  map_public_ip_on_launch = var.public_subnet[count.index].map_public_ip_on_launch
  tags = {
    Name = var.public_subnet[count.index].name
  }
}

resource "aws_subnet" "private_subnet" {
  count                   = length(var.private_subnet)
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = var.private_subnet[count.index].cidr_block
  availability_zone       = var.private_subnet[count.index].availability_zone
  map_public_ip_on_launch = var.private_subnet[count.index].map_public_ip_on_launch
  tags = {
    Name = var.private_subnet[count.index].name
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "public_nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet[0].id
  depends_on    = [aws_internet_gateway.igw]
  tags = {
    Name = "NAT"
  }
}

resource "aws_route" "nat_route" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.public_nat.id
}
