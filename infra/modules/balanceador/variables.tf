# Nombre del proyecto, usado como prefijo en las etiquetas Name de cada recurso
variable "nombre_proyecto" {
  description = "Nombre del proyecto, se usa como prefijo en las etiquetas Name"
  type        = string
}

# ID de la VPC donde se crea el target group
variable "vpc_id" {
  description = "ID de la VPC donde se registra el target group"
  type        = string
}

# IDs de las subredes públicas donde se despliega el balanceador
variable "subnets_publicas_ids" {
  description = "Lista de IDs de subredes públicas para el balanceador"
  type        = list(string)
}

# ID del security group asociado al balanceador (ALB)
variable "sg_alb_id" {
  description = "ID del security group del balanceador"
  type        = string
}

# ID de la instancia de la app que se registra como destino del target group
variable "app_instance_id" {
  description = "ID de la instancia de la app a registrar en el target group"
  type        = string
}

# Puerto de la aplicación; el target apunta al 80 pero se mantiene como referencia
variable "puerto_app" {
  description = "Puerto de la aplicación (referencia; el target apunta al 80)"
  type        = number
  default     = 3000
}
