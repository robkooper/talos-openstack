output "kube_id" {
  description = "OpenStack project name"
  value       = rancher2_cluster.kube.id
}

output "manifest_url" {
  description = "kubectl import command"
  value       = rancher2_cluster.kube.cluster_registration_token[0].manifest_url
}
