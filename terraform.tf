terraform {
  required_providers {
    exoscale = {
      source  = "exoscale/exoscale"
      version = ">= 0.49"
    }
    external = {
      source  = "hashicorp/external"
      version = ">= 2.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.21"
    }
  }

  required_version = ">= 1.0"
}
