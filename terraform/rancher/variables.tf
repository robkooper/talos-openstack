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
