locals {
  base_domain = coalesce(var.base_domain, format("%s.nip.io", replace(exoscale_nlb.this.ip_address, ".", "-")))

  # This local needs to be the same as the key in the nodepools_defaults map.
  # It is used then to pass the proper IDs of the router pool as module outputs.
  router_nodepool = "${var.cluster_name}-router"

  # A default nodepool is created to install Traefik, as recommended in the official documentation
  # https://community.exoscale.com/documentation/sks/loadbalancer-ingress/.
  nodepools_defaults = {
    "${var.cluster_name}-router" = {
      size            = 2
      instance_type   = "standard.small"
      description     = "Router nodepool for ${var.cluster_name} used to avoid loopbacks."
      instance_prefix = null
      disk_size       = null

      taints = {
        nodepool = "router:NoSchedule"
      }
      private_network_ids = null
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
