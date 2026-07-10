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
variable "repo_url" {
  description = "URL publica del repositorio con la app MEAN"
  type        = string
  default     = "https://github.com/yosh-ar/mean-tarea-unir.git"
}
variable "key_name" {
  description = "Nombre del key pair existente en AWS para acceso SSH"
  type        = string
  default     = "devops-unir"
}