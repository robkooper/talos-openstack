output "project_name" {
  description = "OpenStack project name"
  value       = data.openstack_identity_auth_scope_v3.scope.project_name
}

output "nodes" {
  description = "List of nodes created"
  value = [
    for m in local.machines : {
      hostname   = m.hostname
      private_ip = openstack_networking_port_v2.machine_ip[m.hostname].all_fixed_ips[0]
      public_ip  = m.floating_ip ? openstack_networking_floatingip_v2.machine_ip[m.hostname].address : null
    }
  ]
}

output "floating_ip" {
  description = "Map for floating ips and associated private ips"
  value = [
    for i, ip in openstack_networking_floatingip_v2.floating_ip.*.address : {
      private_ip = element(flatten(openstack_networking_port_v2.floating_ip.*.all_fixed_ips), i)
      public_ip  = ip
    }
  ]
}

output "talosconfig" {
  description = "Config file for talosctl"
  value       = data.talos_client_configuration.cluster.talos_config
  sensitive   = true
}

output "kubeconfig" {
  description = "config file for kubectl"
  value       = data.talos_cluster_kubeconfig.cluster.kubeconfig_raw
  sensitive   = true
}

output "kubeclient" {
  description = "client credentials for kubernetes"
  value       = data.talos_cluster_kubeconfig.cluster.kubernetes_client_configuration
  sensitive   = true
}
