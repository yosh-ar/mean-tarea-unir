# PRERREQUISITO: este data source busca la AMI construida con Packer
# (Ubuntu 22.04 + Node 20 + Nginx + unit systemd "app") en la cuenta propia.
# Si no existe ninguna AMI "nodejs-nginx-*", el plan falla aquí mismo.
data "aws_ami" "app" {
  owners      = ["self"]
  most_recent = true

  filter {
    name   = "name"
    values = ["nodejs-nginx-*"]
  }
}

resource "aws_instance" "mongo" {
  ami                    = data.aws_ami.app.id
  instance_type          = var.tipo_instancia
  subnet_id              = var.subnet_privada_id
  vpc_security_group_ids = [var.sg_mongo_id]
  key_name               = var.key_name

  # Instala MongoDB 8.0 en el primer arranque; tarda unos minutos en estar listo
  user_data = file("${path.module}/scripts/mongo.sh")

  tags = {
    Name = "${var.nombre_proyecto}-mongo"
  }
}

resource "aws_instance" "app" {
  ami                         = data.aws_ami.app.id
  instance_type               = var.tipo_instancia
  subnet_id                   = var.subnet_publica_id
  vpc_security_group_ids      = [var.sg_app_id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  # Al referenciar la IP privada de mongo, Terraform crea mongo primero.
  # El script clona repo_url y despliega backend + frontend sobre la AMI base.
  user_data = templatefile("${path.module}/scripts/app.sh.tftpl", {
    mongo_ip   = aws_instance.mongo.private_ip
    puerto_app = var.puerto_app
    repo_url   = var.repo_url
  })

  tags = {
    Name = "${var.nombre_proyecto}-app"
  }
}
