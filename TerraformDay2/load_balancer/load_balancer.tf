# LOAD BALANCER
resource "aws_lb" "npLB" {
  name               = "npLB"
  internal           = false
  load_balancer_type = "network"

  subnet_mapping {
    subnet_id = var.subnet
  }

  enable_deletion_protection = false

  tags = {
    Environment = "dev"
  }
}

# TARGET GROUP FOR HTTPS
resource "aws_lb_target_group" "dev-tcp-443" {
  name     = "AWSnp-tcp-443"
  port     = 443
  protocol = "TCP"
  vpc_id   = var.vpc_id

  health_check {
    protocol            = "HTTP"
    path                = "/healthz"
    port                = 80
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 6
    interval            = 10
    matcher             = "200-399"
  }

}

# TARGET GROUP FOR HTTP
resource "aws_lb_target_group" "dev-tcp-80" {
  name     = "AWSnp-tcp-80"
  port     = 80
  protocol = "TCP"
  vpc_id   = var.vpc_id

  health_check {
    protocol            = "HTTP"
    path                = "/healthz"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 6
    interval            = 10
    matcher             = "200-399"
  }
}

# GROUP ATTACHEMENT TO LOAD BALANCER
# Attach the nodes to the created groups and attach them to the LB
resource "aws_lb_target_group_attachment" "tg-attach-tcp-443-1" {
  count            = length(var.nodes)
  target_group_arn = aws_lb_target_group.dev-tcp-443.arn
  target_id        = element(var.nodes, count.index)
  port             = 443
}

resource "aws_lb_target_group_attachment" "tg-attach-tcp-80-1" {
  count            = length(var.nodes)
  target_group_arn = aws_lb_target_group.dev-tcp-80.arn
  target_id        = element(var.nodes, count.index)
  port             = 80
}

resource "aws_lb_listener" "npLB-listerner-80" {
  load_balancer_arn = aws_lb.npLB.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev-tcp-80.arn
  }
}

resource "aws_lb_listener" "npLB-listerner-443" {
  load_balancer_arn = aws_lb.npLB.arn
  port              = "443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dev-tcp-443.arn
  }
}
