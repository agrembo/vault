resource "aws_lb" "this" {

        name            = var.elb_name

        internal        = false
        load_balancer_type = "application"
        security_groups = [ module.public-sg.this_security_group_id ]
        subnets         = values(module.public_subnets.az_subnet_ids)

        enable_deletion_protection = var.elb_delete_protection

        tags = {

              namespace   = var.namespace
              stage       = var.stage
              name        = var.elb_name
        }

}

resource "aws_lb_listener" "front_end"  {

  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vault.arn
  }

}


resource "aws_lb_target_group" "vault" {
  name     = "vault-target"
  port     = 8200
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
}
