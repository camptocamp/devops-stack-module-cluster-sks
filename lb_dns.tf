resource "exoscale_nlb" "this" {
  zone = var.zone
  name = format("ingress-%s", var.cluster_name)
}

data "exoscale_domain" "this" {
  count = var.base_domain == null ? 0 : 1

  name = var.base_domain
}

resource "exoscale_domain_record" "wildcard_with_cluster_name" {
  count = var.base_domain == null ? 0 : 1

  domain      = data.exoscale_domain.this[count.index].id
  name        = format("*.%s", trimprefix("${var.subdomain}.${var.cluster_name}", "."))
  record_type = "A"
  ttl         = "300"
  content     = resource.exoscale_nlb.this.ip_address
}
