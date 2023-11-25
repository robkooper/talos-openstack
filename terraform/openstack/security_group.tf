resource "openstack_networking_secgroup_v2" "cluster_security_group" {
  name        = var.cluster_name
  description = "${var.cluster_name} kubernetes cluster security group"
}

# ----------------------------------------------------------------------
# Egress
# ----------------------------------------------------------------------

#Egress  IPv4  Any Any 0.0.0.0/0 - - 
#resource "openstack_networking_secgroup_rule_v2" "egress_ipv4" {
#  direction         = "egress"
#  ethertype         = "IPv4"
#  security_group_id = openstack_networking_secgroup_v2.cluster_security_group.id
#  depends_on        = [openstack_networking_secgroup_v2.cluster_security_group]
#}

#Egress  IPv6  Any Any ::/0  - - 
#resource "openstack_networking_secgroup_rule_v2" "egress_ipv6" {
#  direction         = "egress"
#  ethertype         = "IPv6"
#  security_group_id = openstack_networking_secgroup_v2.cluster_security_group.id
#  depends_on        = [openstack_networking_secgroup_v2.cluster_security_group]
#}

# ----------------------------------------------------------------------
# Ingress
# ----------------------------------------------------------------------

# Ingress IPv4  ICMP  Any 0.0.0.0/0 - - 
resource "openstack_networking_secgroup_rule_v2" "ingress_icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  security_group_id = openstack_networking_secgroup_v2.cluster_security_group.id
  depends_on        = [openstack_networking_secgroup_v2.cluster_security_group]
}

# Ingress IPv4  TCP 80 (HTTP) 0.0.0.0/0 - - 
resource "openstack_networking_secgroup_rule_v2" "ingress_http" {
  description       = "http"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  security_group_id = openstack_networking_secgroup_v2.cluster_security_group.id
  depends_on        = [openstack_networking_secgroup_v2.cluster_security_group]
}

# Ingress IPv4  TCP 443 (HTTPS) 0.0.0.0/0 - - 
resource "openstack_networking_secgroup_rule_v2" "ingress_https" {
  description       = "https"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  security_group_id = openstack_networking_secgroup_v2.cluster_security_group.id
  depends_on        = [openstack_networking_secgroup_v2.cluster_security_group]
}

# Ingress IPv4  TCP 50000 (talos api)
resource "openstack_networking_secgroup_rule_v2" "ingress_talos" {
  for_each          = merge(var.openstack_security_talos, { "router" = format("%s/32", openstack_networking_router_v2.kube_router.external_fixed_ip[0].ip_address) })
  description       = "talos api from ${each.key}"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 50000
  port_range_max    = 50000
  remote_ip_prefix  = each.value
  security_group_id = openstack_networking_secgroup_v2.cluster_security_group.id
  depends_on        = [openstack_networking_secgroup_v2.cluster_security_group]
}

# Ingress IPv4  TCP 6443 (kubeapi)
resource "openstack_networking_secgroup_rule_v2" "ingress_kubeapi" {
  for_each          = merge(var.openstack_security_kubernetes, { "router" = format("%s/32", openstack_networking_router_v2.kube_router.external_fixed_ip[0].ip_address) })
  description       = "kubeapi from ${each.key}"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 6443
  port_range_max    = 6443
  remote_ip_prefix  = each.value
  security_group_id = openstack_networking_secgroup_v2.cluster_security_group.id
  depends_on        = [openstack_networking_secgroup_v2.cluster_security_group]
}

# allow all nodes to talk to each other using tcp
resource "openstack_networking_secgroup_rule_v2" "same_security_group_ingress_tcp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  remote_group_id   = openstack_networking_secgroup_v2.cluster_security_group.id
  security_group_id = openstack_networking_secgroup_v2.cluster_security_group.id
  depends_on        = [openstack_networking_secgroup_v2.cluster_security_group]
}

# allow all nodes to talk to each other using udp
resource "openstack_networking_secgroup_rule_v2" "same_security_group_ingress_udp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  remote_group_id   = openstack_networking_secgroup_v2.cluster_security_group.id
  security_group_id = openstack_networking_secgroup_v2.cluster_security_group.id
  depends_on        = [openstack_networking_secgroup_v2.cluster_security_group]
}
