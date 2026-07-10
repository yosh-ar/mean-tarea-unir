# Nombre del proyecto, usado como prefijo en las etiquetas Name de cada recurso
variable "nombre_proyecto" {
  description = "Nombre del proyecto, se usa como prefijo en las etiquetas Name"
  type        = string
}

# Rango CIDR principal de la VPC
variable "vpc_cidr" {
  description = "Rango CIDR de la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# Zonas de disponibilidad donde se despliegan las subredes
variable "azs" {
  description = "Lista de zonas de disponibilidad"
  type        = list(string)
  default     = ["us-east-2a", "us-east-2b"]
}

# Rangos CIDR de las subredes públicas, una por AZ
variable "cidrs_publicas" {
  description = "Lista de CIDR para las subredes públicas"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

# Rango CIDR de la subred privada
variable "cidr_privada" {
  description = "CIDR de la subred privada"
  type        = string
  default     = "10.0.10.0/24"
}
