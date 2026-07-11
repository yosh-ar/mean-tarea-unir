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
module "computo" {
  source = "./modules/computo"

  nombre_proyecto   = var.nombre_proyecto
  subnet_publica_id = module.red.subnets_publicas_ids[0]
  subnet_privada_id = module.red.subnet_privada_id
  sg_app_id         = module.seguridad.sg_app_id
  sg_mongo_id       = module.seguridad.sg_mongo_id
  key_name          = var.key_name
  repo_url          = var.repo_url

  depends_on = [module.red]
}
module "balanceador" {
  source = "./modules/balanceador"

  nombre_proyecto      = var.nombre_proyecto
  vpc_id               = module.red.vpc_id
  subnets_publicas_ids = module.red.subnets_publicas_ids
  sg_alb_id            = module.seguridad.sg_alb_id
  app_instance_id      = module.computo.app_instance_id
}