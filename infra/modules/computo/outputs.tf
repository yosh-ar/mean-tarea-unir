output "app_public_ip" {
  description = "IP pública de la instancia de la app"
  value       = aws_instance.app.public_ip
}

output "app_private_ip" {
  description = "IP privada de la instancia de la app"
  value       = aws_instance.app.private_ip
}

output "mongo_private_ip" {
  description = "IP privada de la instancia de MongoDB"
  value       = aws_instance.mongo.private_ip
}

output "app_instance_id" {
  description = "ID de la instancia de la app"
  value       = aws_instance.app.id
}

output "ami_id" {
  description = "ID de la AMI utilizada"
  value       = data.aws_ami.app.id
}
