resource "aws_vpc" "vpc_cidr" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "Devops Infrastructure VPC"
  }
}

resource "aws_subnet" "subnet_cidr" {
  vpc_id            = aws_vpc.vpc_cidr.id
  cidr_block        = var.subnet_cidr
  availability_zone = var.availability_zone
  # availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "Devops Infrastructure Subnet"
  }
}

resource "aws_internet_gateway" "devops_infra_internet_gateway" {
  vpc_id = aws_vpc.vpc_cidr.id

  tags = {
    Name = "Devops Infrastructure Internet Gateway"
  }
}

resource "aws_route_table" "devops_infra_route_table" {
  vpc_id = aws_vpc.vpc_cidr.id

  tags = {
    Name = "Devops Infrastructure Route Table"
  }
}

resource "aws_route" "subnet_cidr_route" {
  route_table_id         = aws_route_table.devops_infra_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.devops_infra_internet_gateway.id
  depends_on             = [aws_route_table.devops_infra_route_table]
}

resource "aws_route_table_association" "subnet_cidr_to_route_table" {
  subnet_id      = aws_subnet.subnet_cidr.id
  route_table_id = aws_route_table.devops_infra_route_table.id
}

resource "aws_security_group" "devops_infra_allow_ssh" {
  name        = "devops_infra_allow_ssh"
  description = "Allow SSH"
  vpc_id      = aws_vpc.vpc_cidr.id

  tags = {
    Name = "Devops Infrastructure Security Group"
  }
}

resource "aws_security_group_rule" "devops_infra_ingress" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.my_public_ip]
  security_group_id = aws_security_group.devops_infra_allow_ssh.id
}

resource "aws_security_group_rule" "devops_infra_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.devops_infra_allow_ssh.id
}