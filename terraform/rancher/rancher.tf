# ----------------------------------------------------------------------
# cluster definition
# ----------------------------------------------------------------------
resource "rancher2_cluster" "kube" {
  name        = var.cluster_name
  description = var.cluster_description
  driver      = "imported"

  cluster_auth_endpoint {
    enabled = false
  }
}

# ----------------------------------------------------------------------
# cluster access
# ----------------------------------------------------------------------
resource "rancher2_cluster_role_template_binding" "admin_users" {
  for_each          = var.admin_users
  name              = "${rancher2_cluster.kube.id}-user-${replace(each.value, "_", "-")}"
  cluster_id        = rancher2_cluster.kube.id
  role_template_id  = "cluster-owner"
  user_principal_id = replace(var.user_principal_id, "ID", each.value)
  lifecycle {
    ignore_changes = [
      annotations,
      labels,
      user_id
    ]
  }
}

resource "rancher2_cluster_role_template_binding" "admin_groups" {
  for_each           = var.admin_groups
  name               = "${rancher2_cluster.kube.id}-group-${replace(each.value, "_", "-")}"
  cluster_id         = rancher2_cluster.kube.id
  role_template_id   = "cluster-owner"
  group_principal_id = replace(var.group_principal_id, "ID", each.value)
  lifecycle {
    ignore_changes = [
      annotations,
      labels,
      user_id
    ]
  }
}

resource "rancher2_cluster_role_template_binding" "member_users" {
  for_each          = var.member_users
  name              = "${rancher2_cluster.kube.id}-user-${replace(each.value, "_", "-")}"
  cluster_id        = rancher2_cluster.kube.id
  role_template_id  = "cluster-member"
  user_principal_id = replace(var.user_principal_id, "ID", each.value)
  lifecycle {
    ignore_changes = [
      annotations,
      labels,
      user_id
    ]
  }
}

resource "rancher2_cluster_role_template_binding" "member_groups" {
  for_each           = var.member_groups
  name               = "${rancher2_cluster.kube.id}-group-${replace(each.value, "_", "-")}"
  cluster_id         = rancher2_cluster.kube.id
  role_template_id   = "cluster-member"
  group_principal_id = replace(var.group_principal_id, "ID", each.value)
  lifecycle {
    ignore_changes = [
      annotations,
      labels,
      user_id
    ]
  }
}
