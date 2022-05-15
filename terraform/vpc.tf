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

resource "aws_route_table" "web-prod-private-rt" {
  count  = 2
  vpc_id = aws_vpc.web-prod-vpc.id

  tags = {
    Name = "web-prod-private-rt-${count.index}"
  }
}

resource "aws_route_table_association" "web-prod-private-rt-assoc" {
  count          = 2
  subnet_id      = element(aws_subnet.web-prod-subnet-private.*.id, count.index)
  route_table_id = element(aws_route_table.web-prod-private-rt.*.id, count.index)
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

resource "aws_security_group" "vpce-sg" {
  name   = "vpce-sg"
  vpc_id = aws_vpc.web-prod-vpc.id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.web-prod-vpc.cidr_block]
  }
}

resource "aws_vpc_endpoint" "ecr-dkr-vpc-endpoint" {
  vpc_id              = aws_vpc.web-prod-vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = aws_subnet.web-prod-subnet-private.*.id
  security_group_ids  = [aws_security_group.vpce-sg.id]
}

resource "aws_vpc_endpoint" "ecr-api-vpc-endpoint" {
  vpc_id              = aws_vpc.web-prod-vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = aws_subnet.web-prod-subnet-private.*.id
  security_group_ids  = [aws_security_group.vpce-sg.id]
}

resource "aws_vpc_endpoint" "s3-vpc-endpoint" {
  vpc_id            = aws_vpc.web-prod-vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = aws_route_table.web-prod-private-rt.*.id
}

resource "aws_vpc_endpoint" "logs-vpc-endpoint" {
  vpc_id              = aws_vpc.web-prod-vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = aws_subnet.web-prod-subnet-private.*.id
  security_group_ids  = [aws_security_group.vpce-sg.id]
}

resource "aws_vpc_endpoint" "secretsmanager-vpc-endpoint" {
  vpc_id              = aws_vpc.web-prod-vpc.id
  service_name        = "com.amazonaws.${var.aws_region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = aws_subnet.web-prod-subnet-private.*.id
  security_group_ids  = [aws_security_group.vpce-sg.id]
}
