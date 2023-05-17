variable "cluster_name" {
  description = "The name of the Kubernetes cluster to create."
  type        = string
}

variable "base_domain" {
  description = "The base domain used for Ingresses. If not provided, nip.io will be used taking the NLB IP address."
  type        = string
  default     = null
}

variable "domain_id" {
  description = "The ID of the domain created on the caller module. *If the `base_domain` variable is provided, this variable is also required.*"
  type        = string
  default     = null
}

variable "zone" {
  description = "The name of the zone where to deploy the SKS cluster. Available zones can be consulted https://community.exoscale.com/documentation/sks/overview/#availability[here]."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version to use for the SKS cluster. See `exo compute sks versions` for reference. May only be set at creation time."
  type        = string
}

variable "auto_upgrade" {
  description = "Enable automatic upgrade of the SKS cluster."
  type        = bool
  default     = false
}

variable "service_level" {
  description = "Choose the service level for the SKS cluster. _Starter_ can be used for test and development purposes, _Pro_ is recommended for production workloads. The official documentation is available https://community.exoscale.com/documentation/sks/overview/#pricing-tiers[here]."
  type        = string
  default     = "pro"
}

variable "nodepools" {
  description = <<-EOT
  Map containing the SKS node pools to create.
  
  Needs to be a map of maps, where the key is the name of the node pool and the value is a map containing at least the keys `instance_type` and `size`. 
  The other keys are optional: `description`, `instance_prefix`, `disk_size`, `labels`, `taints` and `private_network_ids`. Check the official documentation https://registry.terraform.io/providers/exoscale/exoscale/latest/docs/resources/sks_nodepool[here] for more information.
  EOT
  type        = map(any) # TODO Add validation with the structure of the object instead of using a map of any although I do not see yet how this can work with the lookup function in the nodepool
  default     = null
}

variable "tcp_node_ports_world_accessible" {
  description = "Create a security group rule that allows world access to to NodePort TCP services. Recommended to leave open as per https://community.exoscale.com/documentation/sks/quick-start/#creating-a-cluster-from-the-cli[SKS documentation]."
  type        = bool
  default     = true
}

variable "udp_node_ports_world_accessible" {
  description = "Create a security group rule that allows world access to to NodePort UDP services."
  type        = bool
  default     = false
}
