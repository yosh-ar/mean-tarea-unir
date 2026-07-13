# Este DNS es la URL de entrada de la aplicación.
output "alb_dns_name" {
  description = "Nombre DNS público del balanceador"
  value       = aws_lb.app.dns_name
}

output "alb_arn" {
  description = "ARN del balanceador"
  value       = aws_lb.app.arn
}

output "target_group_arn" {
  description = "ARN del target group"
  value       = aws_lb_target_group.app.arn
}
