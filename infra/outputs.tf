output "ip_publica_app" {
  description = "IP publica de la instancia de aplicacion (Nginx + Node)"
  value       = module.computo.app_public_ip
}

output "ip_privada_app" {
  description = "IP privada de la instancia de aplicacion"
  value       = module.computo.app_private_ip
}

output "ip_privada_mongo" {
  description = "IP privada de la instancia MongoDB (sin IP publica, subred privada)"
  value       = module.computo.mongo_private_ip
}

output "dns_balanceador" {
  description = "DNS publico del Application Load Balancer, punto de entrada de la aplicacion"
  value       = module.balanceador.alb_dns_name
}

output "ip_publica_nat_mongo" {
  description = "IP publica del NAT gateway; cara publica de la salida de MongoDB a internet"
  value       = module.red.nat_public_ip
}