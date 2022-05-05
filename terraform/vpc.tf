data "aws_availability_zones" "available_zones" {
  state = "available"
}

resource "aws_vpc" "web-prod-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = {
    Name = "web-prod-vpc"
  }
}

resource "aws_subnet" "web-prod-subnet-public" {
  count             = 2
  vpc_id            = aws_vpc.web-prod-vpc.id
  cidr_block        = cidrsubnet(aws_vpc.web-prod-vpc.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]

  tags = {
    Name = "web-prod-subnet-public-${count.index}"
  }
}

resource "aws_subnet" "web-prod-subnet-private" {
  count             = 2
  vpc_id            = aws_vpc.web-prod-vpc.id
  cidr_block        = cidrsubnet(aws_vpc.web-prod-vpc.cidr_block, 8, 2 + count.index)
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]

  tags = {
    Name = "web-prod-subnet-private-${count.index}"
  }
}

resource "aws_subnet" "rds-subnet-private" {
  count             = 2
  vpc_id            = aws_vpc.web-prod-vpc.id
  cidr_block        = cidrsubnet(aws_vpc.web-prod-vpc.cidr_block, 8, 4 + count.index)
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]

  tags = {
    Name = "rds-subnet-private-${count.index}"
  }
}

resource "aws_internet_gateway" "web-prod-igw" {
  vpc_id = aws_vpc.web-prod-vpc.id

  tags = {
    Name = "web-prod-igw"
  }
}

resource "aws_route" "web-prod-igw-route" {
  route_table_id         = aws_vpc.web-prod-vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.web-prod-igw.id
}

resource "aws_nat_gateway" "web-prod-nat-gw" {
  count         = 2
  allocation_id = element(aws_eip.web-prod-eip.*.id, count.index)
  subnet_id     = element(aws_subnet.web-prod-subnet-public.*.id, count.index)

  tags = {
    Name = "web-prod-nat-gw-${count.index}"
  }
}

resource "aws_eip" "web-prod-eip" {
  count = 2
  vpc   = true

  tags = {
    Name = "web-prod-eip-${count.index}"
  }
}

resource "aws_route_table" "web-prod-private-rt" {
  count  = 2
  vpc_id = aws_vpc.web-prod-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.web-prod-nat-gw.*.id, count.index)
  }

  tags = {
    Name = "web-prod-private-rt"
  }
}

resource "aws_route_table_association" "web-prod-private-rt-assoc" {
  count          = 2
  subnet_id      = element(aws_subnet.web-prod-subnet-private.*.id, count.index)
  route_table_id = element(aws_route_table.web-prod-private-rt.*.id, count.index)
}
