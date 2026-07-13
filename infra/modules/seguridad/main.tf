# Cadena de acceso en capas: Internet -> ALB (80) -> app (80) -> mongo (27017).
# Cada SG solo acepta tráfico del SG anterior; ninguna regla de mongo mira a Internet.

# name_prefix + create_before_destroy: permite que Terraform reemplace un SG
# sin chocar con el nombre del que todavía está en uso.
resource "aws_security_group" "alb" {
  name_prefix = "${var.nombre_proyecto}-sg-alb-"
  description = "SG del ALB: permite HTTP entrante desde Internet"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.nombre_proyecto}-sg-alb"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "app" {
  name_prefix = "${var.nombre_proyecto}-sg-app-"
  description = "SG de la app: recibe trafico desde el ALB y SSH de administracion"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.nombre_proyecto}-sg-app"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "mongo" {
  name_prefix = "${var.nombre_proyecto}-sg-mongo-"
  description = "SG de MongoDB: recibe trafico solo desde la app"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.nombre_proyecto}-sg-mongo"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  description       = "HTTP entrante desde Internet"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

# La app solo escucha al ALB; nadie llega directo a la instancia por HTTP
# aunque tenga IP pública. Nginx hace el proxy interno hacia Node.
resource "aws_vpc_security_group_ingress_rule" "app_http_desde_alb" {
  security_group_id            = aws_security_group.app.id
  description                  = "HTTP (80) solo desde el ALB; Nginx redirige a Node en localhost"
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
  referenced_security_group_id = aws_security_group.alb.id
}

# OJO: con el default de cidr_ssh (0.0.0.0/0) esto deja SSH abierto a todo
# Internet. Para cualquier uso serio, pasar la IP de administración en cidr_ssh.
resource "aws_vpc_security_group_ingress_rule" "app_ssh" {
  security_group_id = aws_security_group.app.id
  description       = "SSH de administracion. En produccion restringir cidr_ssh."
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = var.cidr_ssh
}

resource "aws_vpc_security_group_ingress_rule" "mongo_desde_app" {
  security_group_id            = aws_security_group.mongo.id
  description                  = "Trafico de MongoDB solo desde la app"
  ip_protocol                  = "tcp"
  from_port                    = var.puerto_mongo
  to_port                      = var.puerto_mongo
  referenced_security_group_id = aws_security_group.app.id
}

# Patrón bastión: para entrar por SSH a mongo hay que saltar primero por la
# instancia de app; la subred privada no tiene otra puerta.
resource "aws_vpc_security_group_ingress_rule" "mongo_ssh_desde_app" {
  security_group_id            = aws_security_group.mongo.id
  description                  = "SSH administrativo solo desde la instancia de app (patron bastion)"
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  referenced_security_group_id = aws_security_group.app.id
}

resource "aws_vpc_security_group_egress_rule" "alb_todo" {
  security_group_id = aws_security_group.alb.id
  description       = "Salida sin restriccion"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "app_todo" {
  security_group_id = aws_security_group.app.id
  description       = "Salida sin restriccion"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "mongo_todo" {
  security_group_id = aws_security_group.mongo.id
  description       = "Salida sin restriccion"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
