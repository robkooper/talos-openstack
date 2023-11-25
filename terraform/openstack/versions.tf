terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = ">= 1.43.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.4.0-alpha.0"
    }
  }
}

provider "openstack" {
  auth_url                      = var.openstack_url
  region                        = "RegionOne"
  application_credential_id     = var.openstack_credential_id
  application_credential_secret = var.openstack_credential_secret
}
