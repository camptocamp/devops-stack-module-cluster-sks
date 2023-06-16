output "cluster_name" {
  description = "Name of the SKS cluster."
  value       = var.cluster_name
}

output "base_domain" {
  description = "The base domain for the SKS cluster."
  value       = local.base_domain
}

output "cluster_id" {
  description = "ID of the SKS cluster."
  value = resource.exoscale_sks_cluster.this.id
}

output "nlb_ip_address" {
  description = "IP address of the Network Load Balancer."
  value       = resource.exoscale_nlb.this.ip_address
}

output "nlb_id" {
  description = "ID of the Network Load Balancer."
  value       = resource.exoscale_nlb.this.id
}

output "router_nodepool_id" {
  description = "ID of the node pool specifically created for Traefik."
  value       = resource.exoscale_sks_nodepool.this[local.router_nodepool].id
}

output "router_instance_pool_id" {
  description = "Instance pool ID of the node pool specifically created for Traefik."
  value       = resource.exoscale_sks_nodepool.this[local.router_nodepool].instance_pool_id
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the SKS nodepool instances."
  value       = resource.exoscale_security_group.this.id
}

output "kubernetes_host" {
  description = "Endpoint for your Kubernetes API server."
  value       = resource.exoscale_sks_cluster.this.endpoint
}

output "kubernetes_cluster_ca_certificate" {
  description = "Certificate Authority required to communicate with the cluster."
  value       = base64decode(local.kubeconfig.clusters.0.cluster.certificate-authority-data)
  sensitive   = true
}

output "kubernetes_client_key" {
  description = "Certificate Client Key required to communicate with the cluster."
  value       = base64decode(local.kubeconfig.users.0.user.client-key-data)
  sensitive   = true
}

output "kubernetes_client_certificate" {
  description = "Certificate Client Certificate required to communicate with the cluster."
  value       = base64decode(local.kubeconfig.users.0.user.client-certificate-data)
  sensitive   = true
}

output "raw_kubeconfig" {
  description = "Raw `.kube/config` file for `kubectl` access."
  value       = resource.exoscale_sks_kubeconfig.this.kubeconfig
  sensitive   = true
}
