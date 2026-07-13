variable "nombre_proyecto" {
  description = "Nombre del proyecto, se usa como prefijo en las etiquetas Name"
  type        = string
}

variable "vpc_cidr" {
  description = "Rango CIDR de la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# Si se cambia la región en el módulo raíz hay que ajustar también estas AZ.
variable "azs" {
  description = "Lista de zonas de disponibilidad"
  type        = list(string)
  default     = ["us-east-2a", "us-east-2b"]
}

# Debe tener la misma longitud que azs: se crea una subred pública por zona.
variable "cidrs_publicas" {
  description = "Lista de CIDR para las subredes públicas"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "cidr_privada" {
  description = "CIDR de la subred privada"
  type        = string
  default     = "10.0.10.0/24"
}
