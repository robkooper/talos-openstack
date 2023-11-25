locals {
  talos_image = format("talos-%s", var.talos_version)

  machines = flatten([
    for x in var.cluster_machines : [
      for i in range(x.count == null ? 1 : x.count) : {
        hostname    = format("%s-%s-%02d", var.cluster_name, x.name, (i + 1))
        image_name  = local.talos_image
        flavor      = try(x.flavor, "gp.medium")
        image_id    = data.openstack_images_image_v2.talos.id
        disk_size   = try(x.disk, 40)
        zone        = try(x.zone, "nova")
        role        = try(x.role, "worker")
        key         = try(x.name, "unknown")
        floating_ip = try(x.floating_ip, can(x.role == "controlplane"))
      }
    ]
  ])

  controlplane1 = [for vm in local.machines : vm.hostname if vm.role == "controlplane"][0]
}


# ----------------------------------------------------------------------
# cluster nodes
# ----------------------------------------------------------------------
resource "openstack_compute_instance_v2" "machine" {
  for_each          = { for vm in local.machines : vm.hostname => vm }
  name              = each.value.hostname
  image_name        = each.value.image_name
  availability_zone = each.value.zone
  flavor_name       = each.value.flavor
  config_drive      = false

  depends_on = [
    openstack_networking_secgroup_rule_v2.same_security_group_ingress_tcp,
    talos_machine_secrets.cluster
  ]

  security_groups = [
    openstack_networking_secgroup_v2.cluster_security_group.name
  ]

  network {
    port = openstack_networking_port_v2.machine_ip[each.key].id
  }

  block_device {
    uuid                  = each.value.image_id
    source_type           = "image"
    volume_size           = each.value.disk_size
    destination_type      = "volume"
    delete_on_termination = true
  }

  user_data = base64encode(data.talos_machine_configuration.cluster[each.value.hostname].machine_configuration)

  lifecycle {
    ignore_changes = [
      user_data,
      block_device,
      availability_zone
    ]
  }
}
