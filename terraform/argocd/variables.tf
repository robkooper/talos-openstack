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

variable "talos_kube_config" {
  type        = map(string)
  description = "kubernetes client config from talos"
}

variable "rancher_kube_id" {
  type        = string
  description = "Rancher cluster id"
}

# ----------------------------------------------------------------------
# ARGOCD
# ----------------------------------------------------------------------
variable "argocd_server_url" {
  type        = string
  description = "Rancher argocd cluster, set to blank to not install argocd"
}

variable "argocd_auth_token" {
  type        = string
  sensitive   = true
  description = "Argocd auth token"
}

variable "argocd_sync" {
  type        = bool
  description = "Should apps automatically sync"
  default     = false
}

variable "argocd_repo_url" {
  type        = string
  description = "URL to pull argocd applications from"
  default     = "https://github.com/robkooper/talos-openstack.git"
}

variable "argocd_repo_path" {
  type        = string
  description = "path in git repo for argocd to get applications from"
  default     = "infrastructure"
}

variable "argocd_repo_version" {
  type        = string
  description = "What version of the application to deploy"
  default     = "HEAD"
}

variable "argocd_annotations" {
  type        = set(string)
  description = "Should argocd be used for infrastructure"
  default     = []
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
# OPENSTACK (for cinder)
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

variable "openstack_project" {
  type        = string
  description = "Openstack project name"
}

# ----------------------------------------------------------------------
# INFRASTRUCTURE APP
# ----------------------------------------------------------------------
variable "sealedsecrets_enabled" {
  type        = bool
  description = "Enable sealed secrets"
  default     = true
}

variable "metallb_floating_ip" {
  type = list(object({
    private_ip = string,
    public_ip  = string
  }))
  description = "List of public/private ip addresses, Private ip addres can be blank. Leave empty to disable metallb"
  default     = []
}

variable "nfs_servers" {
  type = map(object({
    server       = string
    path         = string
    defaultClass = bool
  }))
  description = "values for nfs servers"
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
