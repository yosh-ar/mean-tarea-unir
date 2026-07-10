# ID del security group del ALB
output "sg_alb_id" {
  description = "ID del security group del ALB"
  value       = aws_security_group.alb.id
}

# ID del security group de la aplicación
output "sg_app_id" {
  description = "ID del security group de la aplicación"
  value       = aws_security_group.app.id
}

# ID del security group de MongoDB
output "sg_mongo_id" {
  description = "ID del security group de MongoDB"
  value       = aws_security_group.mongo.id
}
