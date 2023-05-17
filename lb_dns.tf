resource "exoscale_nlb" "this" {
  zone = var.zone
  name = format("ingress-%s", var.cluster_name)
}

data "exoscale_domain" "this" {
  count = var.base_domain == null ? 0 : 1

  name = var.base_domain
}

resource "exoscale_domain_record" "wildcard_colorized" {
  count = var.base_domain == null ? 0 : 1

  domain      = data.exoscale_domain.this[0].id
  name        = format("*.apps.%s", var.cluster_name)
  record_type = "A"
  ttl         = "300"
  content     = resource.exoscale_nlb.this.ip_address
}
