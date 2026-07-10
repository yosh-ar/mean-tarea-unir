# Nombre del proyecto, usado como prefijo en las etiquetas Name de cada recurso
variable "nombre_proyecto" {
  description = "Nombre del proyecto, se usa como prefijo en las etiquetas Name"
  type        = string
}

# ID de la VPC donde se crean los security groups
variable "vpc_id" {
  description = "ID de la VPC donde se crean los security groups"
  type        = string
}

# Puerto en el que escucha la aplicación
variable "puerto_app" {
  description = "Puerto de escucha de la aplicación"
  type        = number
  default     = 3000
}

# Puerto en el que escucha MongoDB
variable "puerto_mongo" {
  description = "Puerto de escucha de MongoDB"
  type        = number
  default     = 27017
}

# CIDR autorizado para SSH (22) sobre el SG de la app.
# ADVERTENCIA: el default 0.0.0.0/0 abre SSH a todo Internet; en producción
# debe restringirse a la IP/rango de administración (por ejemplo, la VPN o bastión).
variable "cidr_ssh" {
  description = "CIDR autorizado para acceso SSH a la app. En producción, restringir."
  type        = string
  default     = "0.0.0.0/0"
}
