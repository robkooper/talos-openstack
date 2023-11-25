locals {
  cluster_def     = jsondecode(file("cluster.json"))
  machines        = local.cluster_def["machines"]
  argocd_security = var.argocd_address == "" ? {} : { "argocd" = var.argocd_address }
}


module "rancher" {
  source = "./rancher"

  cluster_name        = var.cluster_name
  cluster_description = var.cluster_description

  rancher_url   = var.rancher_url
  rancher_token = var.rancher_token

  user_principal_id  = var.user_principal_id
  group_principal_id = var.group_principal_id

  admin_users   = var.admin_users
  admin_groups  = var.admin_groups
  member_users  = var.member_users
  member_groups = var.member_groups
}

module "openstack" {
  source = "./openstack"

  cluster_name        = var.cluster_name
  cluster_description = var.cluster_description

  cluster_machines = local.machines

  openstack_url                 = var.openstack_url
  openstack_credential_id       = var.openstack_credential_id
  openstack_credential_secret   = var.openstack_credential_secret
  openstack_security_kubernetes = merge(var.openstack_security_kubernetes, local.argocd_security)
  openstack_security_talos      = var.openstack_security_talos
  openstack_network_cidr        = var.openstack_network_cidr
  openstack_dns_servers         = var.openstack_dns_servers
  openstack_floating_ip         = var.openstack_floating_ip

  kubernetes_manifests = flatten([module.rancher.manifest_url])
}

module "argocd" {
  source = "./argocd"

  cluster_name        = var.cluster_name
  cluster_description = var.cluster_description

  talos_kube_config = module.openstack.kubeclient

  argocd_server_url = var.argocd_server_url
  argocd_auth_token = var.argocd_auth_token
  argocd_sync       = var.argocd_sync
  #argocd_annotations  = var.argocd_annotations

  admin_users   = var.admin_users
  admin_groups  = var.admin_groups
  member_users  = var.member_users
  member_groups = var.member_groups

  openstack_url               = var.openstack_url
  openstack_credential_id     = var.openstack_credential_id
  openstack_credential_secret = var.openstack_credential_secret
  openstack_project           = module.openstack.project_name

  rancher_kube_id = module.rancher.kube_id
  #rancher_url   = var.rancher_url
  #rancher_token = var.rancher_token

  # load balancer
  metallb_floating_ip = module.openstack.floating_ip

  # gitops secrets
  sealedsecrets_enabled = var.sealedsecrets_enabled

  # monitoring services
  rancher_monitoring_enabled = var.rancher_monitoring_enabled

  # ingress controller
  ingress_controller   = var.ingress_controller
  traefik_storageclass = var.traefik_storageclass
  traefik_ports        = var.traefik_ports
  traefik_acme_server  = var.traefik_acme_server
  traefik_acme_email   = var.traefik_acme_email

  # storage classes
  cinder_enabled    = var.cinder_enabled
  nfs_servers       = var.nfs_servers
  longhorn_replicas = var.longhorn_replicas
}
