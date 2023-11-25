# ----------------------------------------------------------------------
# CLUSTER INFO
# ----------------------------------------------------------------------
variable "cluster_name" {
  type        = string
  description = "Desired name of new cluster"
}

variable "cluster_description" {
  type        = string
  description = "Description of new cluster"
  default     = ""
}

variable "cluster_machines" {
  type        = set(map(any))
  description = "machine definition"
}

# ----------------------------------------------------------------------
# OPENSTACK
# ----------------------------------------------------------------------

variable "openstack_url" {
  type        = string
  description = "OpenStack URL"
}

variable "openstack_credential_id" {
  type        = string
  sensitive   = true
  description = "Openstack credentials"
}

variable "openstack_credential_secret" {
  type        = string
  sensitive   = true
  description = "Openstack credentials"
}

variable "openstack_external_net" {
  type        = string
  description = "OpenStack external network"
  default     = "ext-net"
}

variable "openstack_security_kubernetes" {
  type        = map(any)
  description = "IP address to allow connections to kube api port, default is rancher nodes"
  default     = {}
}

variable "openstack_security_talos" {
  type        = map(any)
  description = "IP address to allow connections to talos api port, default is open to the world"
  default     = {}
}

variable "openstack_network_cidr" {
  type        = string
  description = "CIDR to be used for internal network"
  default     = "192.168.0.0/21"
}

variable "openstack_dns_servers" {
  type        = set(string)
  description = "DNS Servers"
  default     = ["1.1.1.1", "8.8.8.8"]
}

variable "openstack_floating_ip" {
  type        = string
  description = "Number of floating IP addresses available for loadbalancers"
  default     = 2
}

# ----------------------------------------------------------------------
# TALOS
# ----------------------------------------------------------------------

variable "talos_version" {
  type        = string
  description = "Image with most recent talos release"
  default     = "v1.5.5"
}

variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version to install"
  default     = "v1.28.4"
}

variable "kubernetes_manifests" {
  type        = set(string)
  description = "Kubernetes manifests to install"
  default     = []
}
