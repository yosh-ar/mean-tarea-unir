# ID de la VPC creada
output "vpc_id" {
  description = "ID de la VPC"
  value       = aws_vpc.esta.id
}

# Lista de IDs de las subredes públicas
output "subnets_publicas_ids" {
  description = "IDs de las subredes públicas"
  value       = aws_subnet.publicas[*].id
}

# ID de la subred privada
output "subnet_privada_id" {
  description = "ID de la subred privada"
  value       = aws_subnet.privada.id
}

# IP pública del NAT Gateway
output "nat_public_ip" {
  description = "IP pública asociada al NAT Gateway"
  value       = aws_eip.nat.public_ip
}

# ID del Internet Gateway
output "igw_id" {
  description = "ID del Internet Gateway"
  value       = aws_internet_gateway.esta.id
}
