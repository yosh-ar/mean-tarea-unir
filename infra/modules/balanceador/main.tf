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

# El health check pega a "/" (el index de Angular servido por Nginx). Si la
# instancia aparece unhealthy, revisar primero /var/log/user-data.log en la app.
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

# Attachment manual de una sola instancia. Para escalar en serio habría que
# pasar a un Autoscaling Group y dejar que él registre los targets.
resource "aws_lb_target_group_attachment" "app" {
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = var.app_instance_id
  port             = 80
}

# Solo HTTP en el 80; no hay certificado ni listener 443 en esta práctica.
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
