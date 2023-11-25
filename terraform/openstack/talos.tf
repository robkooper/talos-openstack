resource "talos_machine_secrets" "cluster" {}

data "talos_machine_configuration" "cluster" {
  for_each           = { for vm in local.machines : vm.hostname => vm }
  cluster_name       = var.cluster_name
  machine_type       = each.value.role
  cluster_endpoint   = "https://${openstack_networking_floatingip_v2.machine_ip[local.controlplane1].address}:6443"
  machine_secrets    = talos_machine_secrets.cluster.machine_secrets
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version
  docs               = false
  examples           = false
  config_patches = [
    yamlencode({
      machine = {
        network = {
          hostname = each.value.hostname
        }
        install = {
          disk = "/dev/vda"
          wipe = true
        }
        features = {
          kubePrism = {
            enabled = true
            port    = 7445
          }
        }
        nodeLabels = {
          # can't set kubernetes.io/role, so will set ncsa/role instead
          "ncsa/role"   = each.value.role
          "ncsa/flavor" = each.value.flavor
          "ncsa/key"    = each.value.key
        }
      }
      cluster = {
        extraManifests = var.kubernetes_manifests
      }
    })
  ]
}

resource "talos_machine_bootstrap" "cluster" {
  depends_on           = [openstack_compute_instance_v2.machine, talos_machine_secrets.cluster, openstack_networking_secgroup_rule_v2.ingress_talos]
  client_configuration = talos_machine_secrets.cluster.client_configuration
  node                 = openstack_networking_floatingip_v2.machine_ip[local.controlplane1].address
}

data "talos_client_configuration" "cluster" {
  depends_on           = [talos_machine_secrets.cluster, talos_machine_bootstrap.cluster, openstack_networking_secgroup_rule_v2.ingress_talos]
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.cluster.client_configuration
  endpoints            = [for vm in local.machines : openstack_networking_floatingip_v2.machine_ip[vm.hostname].address if vm.role == "controlplane"]
  nodes                = [openstack_networking_floatingip_v2.machine_ip[local.controlplane1].address]
}

data "talos_cluster_kubeconfig" "cluster" {
  depends_on           = [talos_machine_secrets.cluster, talos_machine_bootstrap.cluster, openstack_networking_secgroup_rule_v2.ingress_talos]
  client_configuration = talos_machine_secrets.cluster.client_configuration
  node                 = openstack_networking_floatingip_v2.machine_ip[local.controlplane1].address
}
