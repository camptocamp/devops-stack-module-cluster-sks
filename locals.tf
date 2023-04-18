locals {
  base_domain = coalesce(var.base_domain, format("%s.nip.io", replace(exoscale_nlb.this.ip_address, ".", "-")))
  kubeconfig = yamldecode(module.cluster.kubeconfig)
}
