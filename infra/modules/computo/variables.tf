# Nombre del proyecto, usado como prefijo en las etiquetas Name de cada recurso
variable "nombre_proyecto" {
  description = "Nombre del proyecto, se usa como prefijo en las etiquetas Name"
  type        = string
}

# ID de la subred pública donde se lanza la instancia de la app
variable "subnet_publica_id" {
  description = "ID de la subred pública para la instancia de la app"
  type        = string
}

# ID de la subred privada donde se lanza la instancia de MongoDB
variable "subnet_privada_id" {
  description = "ID de la subred privada para la instancia de MongoDB"
  type        = string
}

# ID del security group de la aplicación
variable "sg_app_id" {
  description = "ID del security group de la aplicación"
  type        = string
}

# ID del security group de MongoDB
variable "sg_mongo_id" {
  description = "ID del security group de MongoDB"
  type        = string
}

# Nombre del key pair de EC2 para acceso SSH a la instancia de la app
variable "key_name" {
  description = "Nombre del key pair de EC2 para acceso SSH"
  type        = string
}

# URL del repositorio Git con el código de la aplicación
variable "repo_url" {
  description = "URL del repositorio Git con el código de la aplicación"
  type        = string
}

# Tipo de instancia EC2 para ambas máquinas
variable "tipo_instancia" {
  description = "Tipo de instancia EC2"
  type        = string
  default     = "t3.micro"
}

# Puerto en el que escucha la aplicación
variable "puerto_app" {
  description = "Puerto de escucha de la aplicación"
  type        = number
  default     = 3000
}
