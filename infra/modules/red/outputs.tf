output "vpc_id" {
  description = "ID de la VPC"
  value       = aws_vpc.esta.id
}

output "subnets_publicas_ids" {
  description = "IDs de las subredes públicas"
  value       = aws_subnet.publicas[*].id
}

output "subnet_privada_id" {
  description = "ID de la subred privada"
  value       = aws_subnet.privada.id
}

output "nat_public_ip" {
  description = "IP pública asociada al NAT Gateway"
  value       = aws_eip.nat.public_ip
}

output "igw_id" {
  description = "ID del Internet Gateway"
  value       = aws_internet_gateway.esta.id
}
