variable "nombre_proyecto" {
  description = "Nombre del proyecto, se usa como prefijo en las etiquetas Name"
  type        = string
}

variable "subnet_publica_id" {
  description = "ID de la subred pública para la instancia de la app"
  type        = string
}

variable "subnet_privada_id" {
  description = "ID de la subred privada para la instancia de MongoDB"
  type        = string
}

variable "sg_app_id" {
  description = "ID del security group de la aplicación"
  type        = string
}

variable "sg_mongo_id" {
  description = "ID del security group de MongoDB"
  type        = string
}

# El key pair debe existir en la región antes del apply; Terraform no lo crea.
variable "key_name" {
  description = "Nombre del key pair de EC2 para acceso SSH"
  type        = string
}

# Debe ser accesible por HTTPS sin credenciales: user_data lo clona con git.
variable "repo_url" {
  description = "URL del repositorio Git con el código de la aplicación"
  type        = string
}

variable "tipo_instancia" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t3.micro"
}

variable "puerto_app" {
  description = "Puerto de escucha de la aplicación"
  type        = number
  default     = 3000
}
