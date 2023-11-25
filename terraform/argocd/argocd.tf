resource "argocd_cluster" "cluster" {
  name   = var.cluster_name
  server = var.talos_kube_config.host

  config {
    tls_client_config {
      ca_data   = base64decode(var.talos_kube_config.ca_certificate)
      cert_data = base64decode(var.talos_kube_config.client_certificate)
      key_data  = base64decode(var.talos_kube_config.client_key)
    }
  }
}

resource "argocd_project" "project" {
  metadata {
    name      = var.cluster_name
    namespace = "argocd"
  }

  depends_on = [argocd_cluster.cluster]

  spec {
    description  = var.cluster_description
    source_repos = ["*"]

    destination {
      server    = var.talos_kube_config.host
      name      = var.cluster_name
      namespace = "*"
    }
    destination {
      server    = "https://kubernetes.default.svc"
      name      = "in-cluster"
      namespace = "cluster-${var.cluster_name}"
    }
    destination {
      server    = "https://kubernetes.default.svc"
      name      = "in-cluster"
      namespace = "argocd"
    }

    cluster_resource_whitelist {
      group = "*"
      kind  = "*"
    }

    role {
      name        = "admin"
      description = "Admin privileges to ${var.cluster_name}"
      groups      = flatten([var.admin_users, var.admin_groups])
      policies = [
        "p, proj:${var.cluster_name}:admin, applications, *, ${var.cluster_name}/*, allow",
      ]
    }
    role {
      name        = "user"
      description = "Read-only privileges to ${var.cluster_name}"
      groups      = flatten([var.member_users, var.member_groups])
      policies = [
        "p, proj:${var.cluster_name}:user, applications, get, ${var.cluster_name}/*, allow",
      ]
    }
  }
}

resource "argocd_application" "infrastructure" {
  metadata {
    name = "${var.cluster_name}-cluster"
    #namespace = "cluster-${var.cluster_name}"
    namespace = "argocd"
    labels = {
      cluster = var.cluster_name
      app     = "infrastructure"
    }
  }

  depends_on = [argocd_cluster.cluster, argocd_project.project]

  spec {
    project = var.cluster_name
    destination {
      server = "https://kubernetes.default.svc"
      #namespace = "cluster-${var.cluster_name}"
      namespace = "argocd"
    }
    sync_policy {
      automated {
        prune       = true
        self_heal   = true
        allow_empty = false
      }
      sync_options = ["CreateNamespace=true"]
    }
    source {
      repo_url        = var.argocd_repo_url
      path            = var.argocd_repo_path
      target_revision = "HEAD"
      helm {
        release_name = var.cluster_name
        values = yamlencode({
          cluster = {
            name      = var.cluster_name
            namespace = "argocd" #"cluster-${var.cluster_name}"
            url       = var.talos_kube_config.host
            rancher = {
              id = var.rancher_kube_id
            }
          }
          openstack = {
            project           = var.openstack_project
            auth_url          = var.openstack_url
            credential_id     = var.openstack_credential_id
            credential_secret = var.openstack_credential_secret
          }
          sync = var.argocd_sync
          raw = {
            enabled = false
          }
          metallb = {
            enabled   = var.metallb_floating_ip != []
            addresses = [for x in var.metallb_floating_ip : x.private_ip == "" ? "${x.public_ip}/32" : "${x.private_ip}/32"]
          }
          certmanager = {
            enabled = true #var.certmanager_enabled
          }
          ingresscontroller = {
            enabled   = var.ingress_controller != ""
            class     = var.ingress_controller
            publicIP  = var.metallb_floating_ip == [] ? "" : var.metallb_floating_ip[0].public_ip
            privateIP = var.metallb_floating_ip == [] ? "" : var.metallb_floating_ip[0].private_ip
            traefik = {
              storageClass = var.traefik_storageclass
              # acme = {
              #   email = var.traefik_acme_email
              #   server = var.traefik_acme_server
              # }
              ports = var.traefik_ports
            }
          }
          sealedsecrets = {
            enabled = var.sealedsecrets_enabled
          }
          monitoring = {
            enabled = var.rancher_monitoring_enabled
          }
          healthmonitor = {
            # deprecated, will leave disabled for now.
            enabled = false
            #           nfs: ${healthmonitor_nfs}
            #           existingSecret: ${healthmonitor_secrets}
          }
          nfs = {
            enabled = var.nfs_servers != []
            servers = var.nfs_servers
          }
          longhorn = {
            enabled  = var.longhorn_replicas > 0
            replicas = var.longhorn_replicas
          }
          cinder = {
            enabled = var.cinder_enabled
          }
        })
      }
    }
  }
}

resource "argocd_repository_credentials" "cluster" {
  count = var.apps_git_url != "" && var.apps_git_password != "" ? 1 : 0

  url      = var.apps_git_url
  username = var.apps_git_username
  password = var.apps_git_password
}

resource "argocd_application" "cluster" {
  count = var.apps_git_url != "" ? 1 : 0

  depends_on = [argocd_cluster.cluster, argocd_project.project, argocd_repository_credentials.cluster]

  metadata {
    name = var.cluster_name
    #namespace = "cluster-${var.cluster_name}"
    namespace = "argocd"
    labels = {
      cluster = var.cluster_name
      app     = "root"
    }
    #   annotations:
    #   #  notifications.argoproj.io/subscribe.on-sync-needs-update.slack: channel
    #   #  notifications.argoproj.io/subscribe.on-sync-succeeded.slack: channel
    #   #  notifications.argoproj.io/subscribe.slack: channel
  }

  spec {
    project = var.cluster_name
    destination {
      server = "https://kubernetes.default.svc"
      #namespace = "cluster-${var.cluster_name}"
      namespace = "argocd"
    }
    sync_policy {
      automated {
        prune       = true
        self_heal   = true
        allow_empty = false
      }
      sync_options = ["CreateNamespace=true"]
    }
    source {
      repo_url        = var.apps_git_url
      path            = var.apps_git_path
      target_revision = var.apps_git_revision
      helm {
        release_name = var.cluster_name
        values = yamlencode({
          cluster = {
            name = var.cluster_name
            url  = var.talos_kube_config.host
            rancher = {
              id = var.rancher_kube_id
            }
          }
        })
      }
    }
  }
}
