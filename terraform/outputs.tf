output "rancher_id" {
  description = "Rancher cluster id"
  value       = module.rancher.kube_id
}

output "kubeconfig" {
  description = "Access to cluster as cluster owner"
  sensitive   = true
  value       = module.openstack.kubeconfig
}

output "talosconfig" {
  description = "Access to cluster as cluster owner"
  sensitive   = true
  value       = module.openstack.talosconfig
}

output "floating_ip" {
  description = "Map for floating ips and associated private ips"
  value       = module.openstack.floating_ip
}

output "openstack_project" {
  description = "OpenStack project name"
  value       = module.openstack.project_name
}

output "kubeclient" {
  description = "client credentials for kubernetes"
  value       = module.openstack.kubeclient
  sensitive   = true
}
