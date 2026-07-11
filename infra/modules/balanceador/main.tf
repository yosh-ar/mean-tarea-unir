# Balanceador de aplicación (ALB) público, distribuido en las subredes públicas
resource "aws_lb" "app" {
  name               = "${var.nombre_proyecto}-alb"
  load_balancer_type = "application"
  internal           = false
  subnets            = var.subnets_publicas_ids
  security_groups    = [var.sg_alb_id]

  tags = {
    Name = "${var.nombre_proyecto}-alb"
  }
}

# Target group HTTP en el puerto 80 con health check sobre la raíz de la app
resource "aws_lb_target_group" "app" {
  name        = "${var.nombre_proyecto}-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/"
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name = "${var.nombre_proyecto}-tg"
  }
}

# Registra la instancia de la app en el target group en el puerto 80
resource "aws_lb_target_group_attachment" "app" {
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = var.app_instance_id
  port             = 80
}

# Listener HTTP en el puerto 80 que reenvía el tráfico al target group
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }

  tags = {
    Name = "${var.nombre_proyecto}-listener"
  }
}
