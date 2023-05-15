resource "exoscale_nlb" "this" {
  zone = var.cluster_zone
  name = format("ingress-%s", var.cluster_name)
}

resource "exoscale_sks_cluster" "this" {
  zone          = var.cluster_zone
  name          = var.cluster_name
  version       = var.cluster_version
  auto_upgrade  = var.cluster_auto_upgrade
  service_level = var.service_level
}

resource "exoscale_anti_affinity_group" "this" {
  for_each = local.nodepools

  name        = format("nodepool-%s", each.key)
  description = "Anti-affinity group to prevent the ${each.key} cluster nodes running on the same physical host."
}

resource "exoscale_sks_nodepool" "this" {
  for_each = local.nodepools

  zone            = var.cluster_zone
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

  # TODO Review the user and groups values (for now, we use the same values as in the official SKS example)
  user   = "kubernetes-admin"
  groups = ["system:masters"]

  # TODO Consider variabilizing this if needed, but I do not think so, as this kubeconfig will only be needed every time a Terraform operation is performed
  # Define a lifetime for the generated kubeconfig file
  ttl_seconds           = 3600 # 1 hour
  early_renewal_seconds = 1800 # 30 minutes
}

resource "local_sensitive_file" "sks_kubeconfig_file" {
  filename        = "${var.cluster_name}-config"
  content         = exoscale_sks_kubeconfig.this.kubeconfig
  file_permission = "0600"
}

# TODO Maybe add wait resource that existed in our SKS cluster module although from my tests I do not think it is needed
