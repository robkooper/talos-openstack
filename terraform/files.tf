resource "local_file" "talosconfig" {
  count                = var.write_files ? 1 : 0
  content              = module.openstack.talosconfig
  filename             = "talosconfig"
  directory_permission = "0700"
  file_permission      = "0600"
}

resource "local_file" "kubeconfig" {
  count                = var.write_files ? 1 : 0
  content              = module.openstack.kubeconfig
  filename             = "kubeconfig"
  directory_permission = "0700"
  file_permission      = "0600"
}
