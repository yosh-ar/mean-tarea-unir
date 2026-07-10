# AMI más reciente construida con Packer (Ubuntu 22.04 + Node 20, Nginx y unit systemd 'app')
data "aws_ami" "app" {
  owners      = ["self"]
  most_recent = true

  filter {
    name   = "name"
    values = ["nodejs-nginx-*"]
  }
}

# Instancia de MongoDB en la subred privada, sin IP pública, alcanzable solo desde la app
resource "aws_instance" "mongo" {
  ami                    = data.aws_ami.app.id
  instance_type          = var.tipo_instancia
  subnet_id              = var.subnet_privada_id
  vpc_security_group_ids = [var.sg_mongo_id]
  key_name               = var.key_name

  # Instala y configura MongoDB 8.0 en el primer arranque
  user_data = file("${path.module}/scripts/mongo.sh")

  tags = {
    Name = "${var.nombre_proyecto}-mongo"
  }
}

# Instancia de la aplicación en la subred pública, con IP pública y acceso SSH por key pair
resource "aws_instance" "app" {
  ami                         = data.aws_ami.app.id
  instance_type               = var.tipo_instancia
  subnet_id                   = var.subnet_publica_id
  vpc_security_group_ids      = [var.sg_app_id]
  associate_public_ip_address = true
  key_name                    = var.key_name

  # Despliega la app apuntando a la IP privada de MongoDB en el primer arranque
  user_data = templatefile("${path.module}/scripts/app.sh.tftpl", {
    mongo_ip   = aws_instance.mongo.private_ip
    puerto_app = var.puerto_app
    repo_url   = var.repo_url
  })

  tags = {
    Name = "${var.nombre_proyecto}-app"
  }
}
