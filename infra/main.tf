terraform {
  required_version = ">= 1.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "red" {
  source = "./modules/red"

  nombre_proyecto = var.nombre_proyecto
}
module "seguridad" {
  source = "./modules/seguridad"

  nombre_proyecto = var.nombre_proyecto
  vpc_id          = module.red.vpc_id
}