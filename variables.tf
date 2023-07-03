variable "cluster_name" {
  description = "The name of the Kubernetes cluster to create."
  type        = string
}

variable "base_domain" {
  description = "The base domain used for Ingresses. If not provided, nip.io will be used taking the NLB IP address."
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
  type = map(object({
    size                = number
    instance_type       = string
    description         = optional(string)
    instance_prefix     = optional(string, "pool")
    disk_size           = optional(number, 50)
    labels              = optional(map(string), {})
    taints              = optional(map(string), {})
    private_network_ids = optional(list(string), [])
  }))
  default = null
}

variable "router_nodepool" {
  description = "Configuration of the router node pool. The defaults of this variable are sensible and rarely need to be changed. *The variable is mainly used to change the size of the node pool when doing cluster upgrades.*"
  type = object({
    size            = number
    instance_type   = string
    instance_prefix = optional(string, "router")
    disk_size       = optional(number, 20)
    labels          = optional(map(string), {})
    taints = optional(map(string), {
      nodepool = "router:NoSchedule"
    })
    private_network_ids = optional(list(string), [])
  })
  default = {
    size          = 2
    instance_type = "standard.small"
  }
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

variable "cni" {
  description = "Specify which CNI to use by default. Accepted values are `calico` or `cilium`, but you cannot change this value after the first deployment. This module creates the required security group rules."
  type        = string
  default     = "cilium"
}

variable "kubeconfig_ttl" {
  description = "Validity period of the kubeconfig file in seconds. See https://registry.terraform.io/providers/exoscale/exoscale/latest/docs/resources/sks_kubeconfig#ttl_seconds[official documentation] for more information."
  type        = number
  default     = 2592000 # 30 days
}

variable "kubeconfig_early_renewal" {
  description = "Renew the kubeconfig file if its age is older than this value in seconds. See https://registry.terraform.io/providers/exoscale/exoscale/latest/docs/resources/sks_kubeconfig#early_renewal_seconds[official documentation] for more information."
  type        = number
  default     = 864000 # 10 days
}

variable "create_kubeconfig_file" {
  description = "Create a Kubeconfig file in the directory where `terraform apply` is run. The file will be named `<cluster_name>-config.yaml`."
  type        = bool
  default     = false
}
