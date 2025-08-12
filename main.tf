resource "exoscale_sks_cluster" "this" {
  zone          = var.zone
  name          = var.cluster_name
  description   = var.description
  version       = var.kubernetes_version
  auto_upgrade  = var.auto_upgrade
  service_level = var.service_level
  cni           = var.cni
  exoscale_csi  = var.enable_csi_driver
}

resource "exoscale_anti_affinity_group" "this" {
  for_each = local.nodepools

  name        = format("nodepool-%s", each.key)
  description = "Anti-affinity group to prevent the ${each.key} cluster nodes running on the same physical host."
}

resource "exoscale_sks_nodepool" "this" {
  for_each = local.nodepools

  zone                    = var.zone
  cluster_id              = resource.exoscale_sks_cluster.this.id
  anti_affinity_group_ids = [resource.exoscale_anti_affinity_group.this[each.key].id]

  name                = each.key
  size                = each.value.size
  instance_type       = each.value.instance_type
  description         = each.value.description
  instance_prefix     = each.value.instance_prefix
  disk_size           = each.value.disk_size
  labels              = each.value.labels
  taints              = each.value.taints
  private_network_ids = each.value.private_network_ids
  security_group_ids  = [resource.exoscale_security_group.this.id]
}

resource "exoscale_sks_kubeconfig" "this" {
  cluster_id = resource.exoscale_sks_cluster.this.id
  zone       = resource.exoscale_sks_cluster.this.zone

  # User and groups values are the same values as in the official SKS example
  user   = "kubernetes-admin"
  groups = ["system:masters"]

  # Define a lifetime for the generated kubeconfig file
  ttl_seconds           = var.kubeconfig_ttl
  early_renewal_seconds = var.kubeconfig_early_renewal
}

resource "local_sensitive_file" "sks_kubeconfig_file" {
  count = var.create_kubeconfig_file ? 1 : 0

  filename        = "${var.cluster_name}-config.yaml"
  content         = resource.exoscale_sks_kubeconfig.this.kubeconfig
  file_permission = "0600"
}
