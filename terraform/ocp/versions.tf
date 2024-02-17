terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.24.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "0.77.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.4.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
  }
  cloud {
    organization = "<ORG_NAME>"
    workspaces {
      name = "path-to-packer"
    }
  }
}
