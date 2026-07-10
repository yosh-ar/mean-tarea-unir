# VPC principal que contiene toda la red del proyecto, con resolución DNS habilitada
resource "aws_vpc" "esta" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.nombre_proyecto}-vpc"
  }
}

# Subredes públicas, una por cada AZ, con asignación automática de IP pública a las instancias
resource "aws_subnet" "publicas" {
  count                   = length(var.cidrs_publicas)
  vpc_id                  = aws_vpc.esta.id
  cidr_block              = var.cidrs_publicas[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.nombre_proyecto}-publica-${count.index + 1}"
  }
}

# Subred privada ubicada en la primera AZ, sin acceso entrante directo desde Internet
resource "aws_subnet" "privada" {
  vpc_id            = aws_vpc.esta.id
  cidr_block        = var.cidr_privada
  availability_zone = var.azs[0]

  tags = {
    Name = "${var.nombre_proyecto}-privada"
  }
}

# Internet Gateway que da salida y entrada a Internet a las subredes públicas
resource "aws_internet_gateway" "esta" {
  vpc_id = aws_vpc.esta.id

  tags = {
    Name = "${var.nombre_proyecto}-igw"
  }
}

# IP elástica que se asocia al NAT Gateway para su dirección pública fija
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.nombre_proyecto}-eip-nat"
  }
}

# NAT Gateway en la primera subred pública, permite salida a Internet a la subred privada
resource "aws_nat_gateway" "esta" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.publicas[0].id

  tags = {
    Name = "${var.nombre_proyecto}-nat"
  }

  # El NAT Gateway requiere que el IGW ya exista para funcionar
  depends_on = [aws_internet_gateway.esta]
}

# Tabla de rutas pública que enruta todo el tráfico externo hacia el Internet Gateway
resource "aws_route_table" "publica" {
  vpc_id = aws_vpc.esta.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.esta.id
  }

  tags = {
    Name = "${var.nombre_proyecto}-rt-publica"
  }
}

# Asociación de la tabla de rutas pública a ambas subredes públicas
resource "aws_route_table_association" "publicas" {
  count          = length(aws_subnet.publicas)
  subnet_id      = aws_subnet.publicas[count.index].id
  route_table_id = aws_route_table.publica.id
}

# Tabla de rutas privada que enruta todo el tráfico externo hacia el NAT Gateway
resource "aws_route_table" "privada" {
  vpc_id = aws_vpc.esta.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.esta.id
  }

  tags = {
    Name = "${var.nombre_proyecto}-rt-privada"
  }
}

# Asociación de la tabla de rutas privada a la subred privada
resource "aws_route_table_association" "privada" {
  subnet_id      = aws_subnet.privada.id
  route_table_id = aws_route_table.privada.id
}
