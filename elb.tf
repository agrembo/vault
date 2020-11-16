resource "aws_elb" "this" {
  name       =  var.elb_name
 
  security_groups = [ module.public-sg.this_security_group_id ]
  subnets         = values(module.public_subnets.az_subnet_ids)


  listener {
    instance_port     = 8500
    instance_protocol = "http"
    lb_port           = 8500
    lb_protocol       = "http"
  }

  listener {
    instance_port     = 8200
    instance_protocol = "http"
    lb_port           = 8200
    lb_protocol       = "http"
  }



  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8500/"
    interval            = 30
  }
 
}