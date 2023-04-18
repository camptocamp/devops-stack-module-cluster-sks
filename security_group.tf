resource "exoscale_security_group_rule" "http" {
  security_group_id = module.cluster.this_security_group_id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 80
  end_port          = 80
}

resource "exoscale_security_group_rule" "https" {
  security_group_id = module.cluster.this_security_group_id
  type              = "INGRESS"
  protocol          = "TCP"
  cidr              = "0.0.0.0/0"
  start_port        = 443
  end_port          = 443
}

resource "exoscale_security_group_rule" "all" {
  security_group_id      = module.cluster.this_security_group_id
  user_security_group_id = module.cluster.this_security_group_id
  type                   = "INGRESS"
  protocol               = "TCP"
  start_port             = 1
  end_port               = 65535
}
