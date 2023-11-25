terraform {
  required_providers {
    argocd = {
      source  = "oboukili/argocd"
      version = ">= 6.0.0"
    }
  }
}

provider "argocd" {
  server_addr = var.argocd_server_url
  auth_token  = var.argocd_auth_token
}
