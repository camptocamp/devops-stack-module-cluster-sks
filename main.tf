module "cluster" {
  source  = "camptocamp/sks/exoscale"
  version = "0.4.1"

  kubernetes_version = var.kubernetes_version
  name               = var.cluster_name
  zone               = var.zone

  nodepools = var.nodepools
}
