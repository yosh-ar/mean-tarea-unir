# Requisitos de providers del módulo. No se declara bloque provider ni backend:
# los módulos hijos heredan el provider configurado en el módulo raíz.
# Restricción laxa (>= 6.0) para que sea la raíz quien fije la versión exacta.
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}
