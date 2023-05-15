# TODO If we don't use the services, move exoscale_nlb to main.tf


# TODO Remove below if not needed

# resource "exoscale_nlb_service" "http" {
#   zone             = resource.exoscale_nlb.this.zone
#   name             = "ingress-controller-http"
#   nlb_id           = resource.exoscale_nlb.this.id
#   instance_pool_id = resource.exoscale_sks_nodepool.this[var.router_nodepool].instance_pool_id
#   protocol         = "tcp"
#   port             = 80
#   target_port      = 80
#   strategy         = "round-robin"

#   healthcheck {
#     mode     = "tcp"
#     port     = 80
#     interval = 5
#     timeout  = 3
#     retries  = 1
#   }
# }

# resource "exoscale_nlb_service" "https" {
#   zone             = resource.exoscale_nlb.this.zone
#   name             = "ingress-controller-https"
#   nlb_id           = resource.exoscale_nlb.this.id
#   instance_pool_id = resource.exoscale_sks_nodepool.this[var.router_nodepool].instance_pool_id
#   protocol         = "tcp"
#   port             = 443
#   target_port      = 443
#   strategy         = "round-robin"

#   healthcheck {
#     mode     = "tcp"
#     port     = 443
#     interval = 5
#     timeout  = 3
#     retries  = 1
#   }
# }
