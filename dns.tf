resource "exoscale_domain" "this" {
  count = var.base_domain == null ? 0 : 1

  name = var.base_domain
}

resource "exoscale_domain_record" "wildcard_short" {
  count = var.base_domain == null ? 0 : 1

  domain      = resource.exoscale_domain.this[0].id
  name        = "*.apps"
  record_type = "A"
  ttl         = "300"
  content     = exoscale_nlb.this.ip_address
}

resource "exoscale_domain_record" "wildcard_long" {
  count = var.base_domain == null ? 0 : 1

  domain      = resource.exoscale_domain.this[0].id
  name        = format("*.apps.%s", var.cluster_name)
  record_type = "A"
  ttl         = "300"
  content     = exoscale_nlb.this.ip_address
}
