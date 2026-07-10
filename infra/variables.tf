variable "region" {
  description = "Región de AWS donde se despliega la infraestructura"
  type        = string
  default     = "us-east-2"
}

variable "nombre_proyecto" {
  description = "Prefijo para el nombre de todos los recursos"
  type        = string
  default     = "mean"
}