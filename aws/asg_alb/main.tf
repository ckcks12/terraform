resource "aws_lb" "this" {
  name               = var.name
  load_balancer_type = "application"
  security_groups    = var.sg_ids
  subnets            = var.subnet_ids
  tags               = var.tag
}

resource "aws_lb_target_group" "this" {
  for_each             = var.ports
  name                 = substr(md5("${var.name}-${each.value}"), 0, 32) // name length limit
  port                 = each.value
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  deregistration_delay = var.deregistration_delay
  tags                 = var.tag
  depends_on           = [aws_lb.this]
}

resource "aws_lb_listener" "this" {
  for_each          = zipmap(keys(var.ports), keys(aws_lb_target_group.this))
  load_balancer_arn = aws_lb.this.arn
  port              = each.key
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.value].arn
  }
  depends_on = [aws_lb.this, aws_lb_target_group.this]
}

resource "aws_autoscaling_attachment" "this" {
  for_each               = aws_lb_target_group.this
  autoscaling_group_name = var.asg_name
  alb_target_group_arn   = aws_lb_target_group.this[each.key].arn
  depends_on             = [aws_lb_target_group.this]
}
