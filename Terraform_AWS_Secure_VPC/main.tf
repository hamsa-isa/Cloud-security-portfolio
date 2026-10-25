# ---------------------------------------------------------------------------
# VPC: the isolated network everything else lives in
# ---------------------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project}-vpc"
  }
}

# ---------------------------------------------------------------------------
# Subnets: 2 public + 2 private, spread across 2 availability zones
# ---------------------------------------------------------------------------
resource "aws_subnet" "public" {
  for_each = var.public_subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = "${var.region}${each.key}"
  map_public_ip_on_launch = false # public IPs are assigned deliberately, never by default

  tags = {
    Name = "${var.project}-public-${each.key}"
    Tier = "public"
  }
}

resource "aws_subnet" "private" {
  for_each = var.private_subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = "${var.region}${each.key}"

  tags = {
    Name = "${var.project}-private-${each.key}"
    Tier = "private"
  }
}

# ---------------------------------------------------------------------------
# Internet gateway: the VPC's connection to the internet
# ---------------------------------------------------------------------------
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project}-igw"
  }
}

# ---------------------------------------------------------------------------
# Public routing: 0.0.0.0/0 -> internet gateway, explicitly associated
# ---------------------------------------------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# ---------------------------------------------------------------------------
# NAT gateway: outbound-only internet access for private subnets
# (single NAT to keep lab costs down; production would use one per AZ)
# ---------------------------------------------------------------------------
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.project}-nat-eip"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public["a"].id

  tags = {
    Name = "${var.project}-nat"
  }

  depends_on = [aws_internet_gateway.main]
}

# ---------------------------------------------------------------------------
# Private routing: 0.0.0.0/0 -> NAT gateway, explicitly associated
# ---------------------------------------------------------------------------
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.project}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

# ---------------------------------------------------------------------------
# Security groups
# ---------------------------------------------------------------------------
resource "aws_security_group" "app" {
  name        = "${var.project}-app-sg"
  description = "App servers: HTTPS from inside the VPC only"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project}-app-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "app_https" {
  security_group_id = aws_security_group.app.id
  description       = "HTTPS from inside the VPC"
  cidr_ipv4         = var.vpc_cidr
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "app_all_out" {
  security_group_id = aws_security_group.app.id
  description       = "Allow all outbound"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Adopts the AWS-created default security group and strips all its rules
# (CIS AWS Foundations Benchmark recommendation)
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project}-default-sg-locked"
  }
}
