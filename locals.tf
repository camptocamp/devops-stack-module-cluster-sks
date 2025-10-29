locals {
  base_domain           = coalesce(var.base_domain, format("%s.nip.io", replace(exoscale_nlb.this.ip_address, ".", "-")))
  default_nodepool_name = "${var.cluster_name}-default"

  nodepools_defaults = {
    "${local.default_nodepool_name}" = {
      size                = var.default_nodepool.size
      instance_type       = var.default_nodepool.instance_type
      description         = "Default node pool for ${var.cluster_name} used to avoid loopbacks."
      instance_prefix     = var.default_nodepool.instance_prefix
      disk_size           = var.default_nodepool.disk_size
      labels              = var.default_nodepool.labels
      taints              = var.default_nodepool.taints
      private_network_ids = var.default_nodepool.private_network_ids
    },
  }

  # This local merges the incoming nodepools and defaults into a single map to be used by our main resources.
  # Note that besides the router nodepool, there is no other nodepool defined by default.
  nodepools = merge(
    local.nodepools_defaults,
    var.nodepools,
  )

  # Decode the YAML kubeconfig file into a structured value in order to generate separate outputs for each of its fields
  kubeconfig = yamldecode(resource.exoscale_sks_kubeconfig.this.kubeconfig)
}
