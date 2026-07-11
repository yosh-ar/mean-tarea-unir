# Nombre DNS público del balanceador, punto de entrada de la aplicación
output "alb_dns_name" {
  description = "Nombre DNS público del balanceador"
  value       = aws_lb.app.dns_name
}

# ARN del balanceador
output "alb_arn" {
  description = "ARN del balanceador"
  value       = aws_lb.app.arn
}

# ARN del target group
output "target_group_arn" {
  description = "ARN del target group"
  value       = aws_lb_target_group.app.arn
}
