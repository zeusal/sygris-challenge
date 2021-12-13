terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.69.0"
    }
  }
}

resource "aws_vpc" "main" {
  cidr_block           = "${var.base_cidr_block}"
  instance_tenancy     = "default"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support   = "${var.enable_dns_support}"
  tags = {
    Name = "${var.scope}-VPC"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id     = aws_vpc.main.id
  depends_on = [aws_vpc.main]
  tags = {
    Name = "gw-${var.project}"
  }
}

resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.default]
}

resource "aws_subnet" "public" {
  depends_on              = [aws_vpc.main]
  vpc_id                  = aws_vpc.main.id
  count                   = length("${var.public_subnets_cidr}")
  cidr_block              = element("${var.public_subnets_cidr}", count.index)
  availability_zone       = element("${var.availability_zones}", count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project}-${element("${var.availability_zones}", count.index)}-pub"
  }
}

resource "aws_subnet" "private" {
  depends_on              = [aws_vpc.main]
  vpc_id                  = aws_vpc.main.id
  count                   = length("${var.private_subnets_cidr}")
  cidr_block              = element("${var.private_subnets_cidr}", count.index)
  availability_zone       = element("${var.availability_zones}", count.index)
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project}-${element("${var.availability_zones}", count.index)}-priv"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public.*.id, 0)
  depends_on    = [aws_internet_gateway.default]
  tags = {
    Name = "${var.project}-nat"
  }
}

resource "aws_route_table" "private" {
  depends_on = [aws_vpc.main, aws_nat_gateway.nat, aws_internet_gateway.default]
  vpc_id     = aws_vpc.main.id

  tags = {
    Name = "${var.project}-priv-rt"
  }
}

resource "aws_route_table" "public" {
  depends_on = [aws_vpc.main, aws_nat_gateway.nat, aws_internet_gateway.default]
  vpc_id     = aws_vpc.main.id

  tags = {
    Name = "${var.project}-pub-rt"
  }
}

resource "aws_route" "public_internet_gateway" {
  depends_on             = [aws_route_table.public]
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

resource "aws_route" "private_nat_gateway" {
  depends_on             = [aws_route_table.private]
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "public" {
  depends_on     = [aws_route.public_internet_gateway]
  count          = length("${var.public_subnets_cidr}")
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  depends_on     = [aws_route.private_nat_gateway]
  count          = length("${var.private_subnets_cidr}")
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "default" {
  name        = "${var.project}-default-SG"
  description = "Default SG to allow inbound/outbound from the VPC"
  vpc_id      = aws_vpc.main.id
  depends_on  = [aws_vpc.main]

  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = "true"
  }

  tags = {
    Name = "${var.project}-default-SG"
  }
}

resource "aws_security_group" "internet" {
  name        = "${var.project}-internet-SG"
  description = "Default SG to allow internet outbound from the VPC"
  vpc_id      = aws_vpc.main.id
  depends_on  = [aws_vpc.main]

  egress {
    from_port  = "0"
    to_port   = "0"
    protocol  = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.project}-internet-SG"
  }
}

resource "aws_security_group" "ssh" {
  name               = "${var.project}-ssh-SG"
  description        = "Allow SSH inbound traffic"
  vpc_id             = aws_vpc.main.id
  depends_on  = [aws_vpc.main]

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.project}-ssh-SG"
  }
}