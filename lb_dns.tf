resource "exoscale_nlb" "this" {
  zone = var.zone
  name = format("ingress-%s", var.cluster_name)
}

resource "exoscale_domain_record" "wildcard_colorized" {
  count = var.base_domain == null ? 0 : 1

  domain      = var.domain_id
  name        = format("*.apps.%s", var.cluster_name)
  record_type = "A"
  ttl         = "300"
  content     = resource.exoscale_nlb.this.ip_address
}
