resource "aws_vpc" "web-prod-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = {
    Name = "web-prod-vpc"
  }
}

resource "aws_subnet" "web-prod-subnet-public-1" {
  vpc_id            = aws_vpc.web-prod-vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-central-1a"

  tags = {
    Name = "web-prod-subnet-public-1"
  }
}

resource "aws_subnet" "web-prod-subnet-public-2" {
  vpc_id            = aws_vpc.web-prod-vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "eu-central-1b"

  tags = {
    Name = "web-prod-subnet-public-2"
  }
}

resource "aws_subnet" "web-prod-subnet-public-3" {
  vpc_id            = aws_vpc.web-prod-vpc.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = "eu-central-1c"

  tags = {
    Name = "web-prod-subnet-public-3"
  }
}

resource "aws_subnet" "web-prod-subnet-private-1" {
  vpc_id     = aws_vpc.web-prod-vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "web-prod-subnet-private-1"
  }
}

resource "aws_internet_gateway" "web-prod-igw" {
  vpc_id = aws_vpc.web-prod-vpc.id

  tags = {
    Name = "web-prod-igw"
  }
}

resource "aws_route" "web-prod-public-route" {
  route_table_id         = aws_vpc.web-prod-vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.web-prod-igw.id
}

resource "aws_nat_gateway" "web-prod-nat-gw-1" {
  allocation_id = aws_eip.web-prod-eip-1.id
  subnet_id     = aws_subnet.web-prod-subnet-public-1.id

  tags = {
    Name = "web-prod-nat-gw-1"
  }
}

resource "aws_nat_gateway" "web-prod-nat-gw-2" {
  allocation_id = aws_eip.web-prod-eip-2.id
  subnet_id     = aws_subnet.web-prod-subnet-public-2.id

  tags = {
    Name = "web-prod-nat-gw-2"
  }
}

resource "aws_nat_gateway" "web-prod-nat-gw-3" {
  allocation_id = aws_eip.web-prod-eip-3.id
  subnet_id     = aws_subnet.web-prod-subnet-public-3.id

  tags = {
    Name = "web-prod-nat-gw-3"
  }
}

resource "aws_eip" "web-prod-eip-1" {
  vpc = true

  tags = {
    Name = "web-prod-eip-1"
  }
}

resource "aws_eip" "web-prod-eip-2" {
  vpc = true

  tags = {
    Name = "web-prod-eip-2"
  }
}

resource "aws_eip" "web-prod-eip-3" {
  vpc = true

  tags = {
    Name = "web-prod-eip-3"
  }
}

resource "aws_route_table" "web-prod-private-rt" {
  vpc_id = aws_vpc.web-prod-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.web-prod-nat-gw-1.id
  }

  tags = {
    Name = "web-prod-private-rt"
  }
}

resource "aws_route_table_association" "web-prod-private-rt-assoc" {
  subnet_id      = aws_subnet.web-prod-subnet-private-1.id
  route_table_id = aws_route_table.web-prod-private-rt.id
}

resource "aws_security_group" "web-prod-ecs-sg" {
  name        = "web-prod-ecs-sg"
  vpc_id      = aws_vpc.web-prod-vpc.id
  description = "allow inbound access from the ALB only"

  ingress {
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    security_groups = [aws_security_group.web-prod-lb-sg.id]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "web-prod-lb-sg" {
  name        = "web-prod-lb-sg"
  vpc_id      = aws_vpc.web-prod-vpc.id
  description = "controls access to the ALB"

  ingress {
    protocol         = "tcp"
    from_port        = 80
    to_port          = 80
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
