resource "exoscale_sks_cluster" "this" {
  zone          = var.zone
  name          = var.cluster_name
  version       = var.kubernetes_version
  auto_upgrade  = var.auto_upgrade
  service_level = var.service_level
  cni           = var.cni
}

resource "exoscale_anti_affinity_group" "this" {
  for_each = local.nodepools

  name        = format("nodepool-%s", each.key)
  description = "Anti-affinity group to prevent the ${each.key} cluster nodes running on the same physical host."
}

resource "exoscale_sks_nodepool" "this" {
  for_each = local.nodepools

  zone            = var.zone
  cluster_id      = resource.exoscale_sks_cluster.this.id
  name            = each.key
  description     = lookup(each.value, "description", "")
  instance_type   = each.value.instance_type
  instance_prefix = lookup(each.value, "instance_prefix", "pool")
  disk_size       = lookup(each.value, "disk_size", "50")
  size            = each.value.size
  labels          = lookup(each.value, "labels", {})
  taints          = lookup(each.value, "taints", {})

  anti_affinity_group_ids = [resource.exoscale_anti_affinity_group.this[each.key].id]
  security_group_ids      = [resource.exoscale_security_group.this.id]
  private_network_ids     = lookup(each.value, "private_network_ids", [])
}

resource "exoscale_sks_kubeconfig" "this" {
  cluster_id = resource.exoscale_sks_cluster.this.id
  zone       = resource.exoscale_sks_cluster.this.zone

  # User and groups values are the same values as in the official SKS example
  user   = "kubernetes-admin"
  groups = ["system:masters"]

  # Define a lifetime for the generated kubeconfig file
  ttl_seconds           = 259200 # 72 hours
  early_renewal_seconds = 86400  # 24 hours
}

resource "local_sensitive_file" "sks_kubeconfig_file" {
  filename        = "${var.cluster_name}-config"
  content         = resource.exoscale_sks_kubeconfig.this.kubeconfig
  file_permission = "0600"
}

# TODO Add comment here explaining the reason for this resource and that it needs to have the kubernetes provider configured on the caller module
resource "kubernetes_config_map_v1_data" "coredns_configmap_overload" {
  metadata {
    name      = "coredns"
    namespace = "kube-system"
  }

  force = true

  data = {
    Corefile = <<-EOF
    .:53 {
        log
        errors
        health {
          lameduck 5s
        }
        ready
        kubernetes ${resource.exoscale_sks_cluster.this.id}.cluster.local cluster.local in-addr.arpa ip6.arpa {
          pods verified
          fallthrough in-addr.arpa ip6.arpa
        }
        forward . /etc/resolv.conf
        prometheus :9153
        cache 300
        loop
        reload
        loadbalance
    }
    EOF
  }
}

data "kubernetes_config_map" "coredns_configmap" {
  metadata {
    name      = "coredns"
    namespace = "kube-system"
  }
  depends_on = [
    resource.kubernetes_config_map_v1_data.coredns_configmap_overload,
    resource.exoscale_sks_cluster.this,
  ]
}

# TODO Document the need to have kubectl working and installed
resource "null_resource" "coredns_restart" {
  depends_on = [
    resource.kubernetes_config_map_v1_data.coredns_configmap_overload
  ]
  triggers = {
    coredns_configmap_hash = data.kubernetes_config_map.coredns_configmap.metadata[0].annotations["kubectl.kubernetes.io/last-applied-configuration"]
  }
  provisioner "local-exec" {
    command = <<-EOT
      kubectl --kubeconfig="${var.cluster_name}-config" delete pod $(kubectl --kubeconfig="${var.cluster_name}-config" get pods -n kube-system | grep coredns | cut -d ' ' -f 1) -n kube-system
    EOT
  }
}
