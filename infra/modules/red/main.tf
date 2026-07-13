resource "aws_vpc" "esta" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.nombre_proyecto}-vpc"
  }
}

# Una subred pública por AZ: el ALB exige al menos dos zonas distintas.
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

# Aquí vive MongoDB: sin ruta de entrada desde Internet, solo salida vía NAT.
resource "aws_subnet" "privada" {
  vpc_id            = aws_vpc.esta.id
  cidr_block        = var.cidr_privada
  availability_zone = var.azs[0]

  tags = {
    Name = "${var.nombre_proyecto}-privada"
  }
}

resource "aws_internet_gateway" "esta" {
  vpc_id = aws_vpc.esta.id

  tags = {
    Name = "${var.nombre_proyecto}-igw"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.nombre_proyecto}-eip-nat"
  }
}

# Un solo NAT en la primera AZ para abaratar (cada NAT + EIP tiene coste fijo por hora).
# El compromiso: si esa zona cae, la subred privada se queda sin salida a Internet.
resource "aws_nat_gateway" "esta" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.publicas[0].id

  tags = {
    Name = "${var.nombre_proyecto}-nat"
  }

  # Terraform no infiere este orden por las referencias y sin el IGW adjunto
  # la creación del NAT falla de forma intermitente.
  depends_on = [aws_internet_gateway.esta]
}

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

resource "aws_route_table_association" "publicas" {
  count          = length(aws_subnet.publicas)
  subnet_id      = aws_subnet.publicas[count.index].id
  route_table_id = aws_route_table.publica.id
}

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

resource "aws_route_table_association" "privada" {
  subnet_id      = aws_subnet.privada.id
  route_table_id = aws_route_table.privada.id
}
