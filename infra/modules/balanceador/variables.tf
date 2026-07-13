variable "nombre_proyecto" {
  description = "Nombre del proyecto, se usa como prefijo en las etiquetas Name"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC donde se registra el target group"
  type        = string
}

variable "subnets_publicas_ids" {
  description = "Lista de IDs de subredes públicas para el balanceador"
  type        = list(string)
}

variable "sg_alb_id" {
  description = "ID del security group del balanceador"
  type        = string
}

variable "app_instance_id" {
  description = "ID de la instancia de la app a registrar en el target group"
  type        = string
}

# El target group apunta al 80 (Nginx); este puerto queda solo como referencia
# del backend Node que corre detrás del proxy.
variable "puerto_app" {
  description = "Puerto de la aplicación (referencia; el target apunta al 80)"
  type        = number
  default     = 3000
}
