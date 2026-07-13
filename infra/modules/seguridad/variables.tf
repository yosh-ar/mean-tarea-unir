variable "nombre_proyecto" {
  description = "Nombre del proyecto, se usa como prefijo en las etiquetas Name"
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC donde se crean los security groups"
  type        = string
}

variable "puerto_mongo" {
  description = "Puerto de escucha de MongoDB"
  type        = number
  default     = 27017
}

# El default 0.0.0.0/0 abre SSH a todo Internet; se deja así solo para facilitar
# la práctica. En producción, pasar aquí la IP o rango de administración.
variable "cidr_ssh" {
  description = "CIDR autorizado para acceso SSH a la app. En producción, restringir."
  type        = string
  default     = "0.0.0.0/0"
}
