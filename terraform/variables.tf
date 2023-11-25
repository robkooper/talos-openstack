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

variable "write_files" {
  type        = bool
  description = "Write out the talosconfig/kubeconfig"
  default     = false
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
  description = "IP address to allow connections to kube api port"
  default = {
    "world" : "0.0.0.0/0"
  }
}

variable "openstack_security_talos" {
  type        = map(any)
  description = "IP address to allow connections to talos api port, default is open to the world"
  default = {
    "world" : "0.0.0.0/0"
  }
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

# ----------------------------------------------------------------------
# RANCHER
# ----------------------------------------------------------------------

variable "rancher_url" {
  type        = string
  description = "URL where rancher runs"
}

variable "rancher_token" {
  type        = string
  sensitive   = true
  description = "Access token for rancher, clusters are created as this user"
}

variable "user_principal_id" {
  type        = string
  description = "User ID for rancher user, ID is placeholder for the user"
  default     = "ID"
}

variable "group_principal_id" {
  type        = string
  description = "Group ID for rancher group, ID is placeholder for the group"
  default     = "ID"
}

# ----------------------------------------------------------------------
# USERS
# ----------------------------------------------------------------------

variable "admin_users" {
  type        = set(string)
  description = "List of LDAP users with admin access to cluster."
  default     = []
}

variable "admin_groups" {
  type        = set(string)
  description = "List of LDAP groups with admin access to cluster."
  default     = []
}

variable "member_users" {
  type        = set(string)
  description = "List of LDAP users with access to cluster."
  default     = []
}

variable "member_groups" {
  type        = set(string)
  description = "List of LDAP groups with access to cluster."
  default     = []
}

# ----------------------------------------------------------------------
# ARGOCD
# ----------------------------------------------------------------------

variable "argocd_server_url" {
  type        = string
  description = "URL for argocd server"
  default     = ""
}

variable "argocd_auth_token" {
  type        = string
  sensitive   = true
  description = "Argocd auth token"
}

variable "argocd_address" {
  type        = string
  description = "Argocd ip address for firewall"
  default     = ""
}

variable "argocd_sync" {
  type        = bool
  description = "Should apps automatically sync"
  default     = true
}

# ----------------------------------------------------------------------
# INFRASTRUCTURE APP
# ----------------------------------------------------------------------
variable "sealedsecrets_enabled" {
  type        = bool
  description = "Enable sealed secrets"
  default     = true
}

variable "nfs_servers" {
  type = map(object({
    server       = string
    path         = string
    defaultClass = bool
  }))
  description = "values for nfs servers, set to empty to no install nfs"
  default     = {}
}

variable "cinder_enabled" {
  type        = bool
  description = "Enable cinder storage"
  default     = true
}

variable "longhorn_replicas" {
  type        = string
  description = "Number of replicas, set this to 0 to disable longhorn"
  default     = 0
}

variable "rancher_monitoring_enabled" {
  type        = bool
  description = "Enable rancher monitoring"
  default     = true
}

variable "ingress_controller" {
  type        = string
  description = "Desired ingress controller (traefik, nginx) leave blank to disable"
  default     = "traefik"
  validation {
    condition     = var.ingress_controller == "nginx" || var.ingress_controller == "traefik"
    error_message = "Invalid ingress controller."
  }
}

# ----------------------------------------------------------------------
# TRAEFIK
# ----------------------------------------------------------------------

variable "traefik_access_log" {
  type        = bool
  description = "Should traefik enable access logs"
  default     = false
}

variable "traefik_storageclass" {
  type        = string
  description = "storageclass used by ingress controller"
  default     = ""
}

variable "traefik_ports" {
  type        = map(any)
  description = "Additional ports to add to traefik"
  default     = {}
}

variable "traefik_acme_server" {
  type        = string
  description = "URL for the acme server"
  default     = "https://acme-v02.api.letsencrypt.org/directory"
  # defualt   = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

variable "traefik_acme_email" {
  type        = string
  description = "Use the following email for cert messages"
  default     = "devops@example.com"
}

# ----------------------------------------------------------------------
# USER APPS
# ----------------------------------------------------------------------
variable "apps_git_url" {
  type        = string
  description = "URL for git reposiory to pull root apps from"
  default     = ""
}

variable "apps_git_username" {
  type        = string
  description = "Revision of root apps to deploy"
  default     = "terraform"
}

variable "apps_git_password" {
  type        = string
  description = "Revision of root apps to deploy"
  default     = ""
}

variable "apps_git_path" {
  type        = string
  description = "Path to root apps in git repo"
  default     = "charts/apps"
}

variable "apps_git_revision" {
  type        = string
  description = "Revision of root apps to deploy"
  default     = "HEAD"
}

# ----------------------------------------------------------------------
# TWEAKS
# ----------------------------------------------------------------------

variable "cloudflare_domain" {
  type        = string
  description = "Domain for the DNS entries"
  default     = "example.com"
}

variable "cloudflare_api_token" {
  type        = string
  description = "DNS key for cloudflare, default means don't use"
  default     = "00000000000000000000-00000000000000000000"
}
