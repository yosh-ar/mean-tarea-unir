# Security group del balanceador de carga (ALB), expuesto a Internet en HTTP
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

# Security group de la aplicación, solo recibe tráfico desde el ALB (y SSH de administración)
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

# Security group de MongoDB, solo recibe tráfico desde la aplicación
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

# Ingress ALB: HTTP (80) abierto a todo Internet
resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  description       = "HTTP entrante desde Internet"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

# Ingress app: puerto de la app únicamente desde el SG del ALB
resource "aws_vpc_security_group_ingress_rule" "app_desde_alb" {
  security_group_id            = aws_security_group.app.id
  description                  = "Trafico de la app solo desde el ALB"
  ip_protocol                  = "tcp"
  from_port                    = var.puerto_app
  to_port                      = var.puerto_app
  referenced_security_group_id = aws_security_group.alb.id
}

# Ingress app: SSH (22) desde el CIDR de administración. En producción debe restringirse.
resource "aws_vpc_security_group_ingress_rule" "app_ssh" {
  security_group_id = aws_security_group.app.id
  description       = "SSH de administracion. En produccion restringir cidr_ssh."
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = var.cidr_ssh
}

# Ingress mongo: puerto de MongoDB únicamente desde el SG de la app
resource "aws_vpc_security_group_ingress_rule" "mongo_desde_app" {
  security_group_id            = aws_security_group.mongo.id
  description                  = "Trafico de MongoDB solo desde la app"
  ip_protocol                  = "tcp"
  from_port                    = var.puerto_mongo
  to_port                      = var.puerto_mongo
  referenced_security_group_id = aws_security_group.app.id
}

# Egress ALB: salida sin restricción a todo Internet
resource "aws_vpc_security_group_egress_rule" "alb_todo" {
  security_group_id = aws_security_group.alb.id
  description       = "Salida sin restriccion"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# Egress app: salida sin restricción a todo Internet
resource "aws_vpc_security_group_egress_rule" "app_todo" {
  security_group_id = aws_security_group.app.id
  description       = "Salida sin restriccion"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# Egress mongo: salida sin restricción a todo Internet
resource "aws_vpc_security_group_egress_rule" "mongo_todo" {
  security_group_id = aws_security_group.mongo.id
  description       = "Salida sin restriccion"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
