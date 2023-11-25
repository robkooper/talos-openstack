# openstack/terraform/talos

This requires the talos images to be uploaded, this can be done using the `images.sh` script in the terraform folder.

## kubernetes versions and talos

This table lists the latest versions of talos and kubernetes and their support (`curl -s https://endoflife.date/api/kubernetes.json | jq -r '.[].latest'`).

| talos        | v1.29-alpha | v1.28.4 | V1.27.8 | V1.26.11 | v1.25.16 | 1.24.17 |
| ------------ | :---------: | :-----: | :-----: | :------: | :------: | :-----: |
| v1.6.0-alpha |      X      |    X    |    X    |    X     |    X     |    X    |
| v1.5.5       |             |    X    |    X    |    X     |    -     |         |
| v1.4.8       |             |         |    X    |    X     |    X     |         |

# Creating a cluster

Use `tofu init` to initialize the framework and `tofu apply` to create the cluster. The system will run the following modules in order:

- **rancher** : create a cluster in rancher and add users/groups. This is used to control access to the cluster.
- **openstack** : create a cluster in openstack. This creates the nodes, network, ip addresses. This will import the cluster into rancher.
- **argocd** : create a project in argocd and add infrastructure componnets. Users in rancher are also added to argocd

The cluster might not be ready when **argocd** is executed (waiting for cluster) resulting in a failure. Please run `tofu apply` again to finish setting up the cluster.

## Variables

Below are the variables you can change to modify the cluster created. You can use `terraform.tfvars` or files with the name 
`XYZ.auto.tfvars`. The latter is ignored by git (using .gitignore) and can be used to store secrets you don't want to commit. 
(1) These variables that do not have a default value and need to be configured.
(2) These values are set to open and for security should be modified

### Cluster

The name and description of the cluster and write kubconfig/talosconfig to disk

| name                | description                          | default value |
| ------------------- | ------------------------------------ | ------------- |
| cluster_name        | Desired name of new cluster (1)      |               |
| cluster_description | Description of new cluster           | ""            |
| write_files         | Write out the talosconfig/kubeconfig | false         |

### Users

This is the list of users that will have access through rancher to the cluster as well as the project in argocd.

| name                          | description                                                  | default value                             |
| ----------------------------- | ------------------------------------------------------------ | ----------------------------------------- |
| admin_users                   | List of LDAP users with admin access to cluster.             | []                                        |
| admin_groups                  | List of LDAP groups with admin access to cluster.            | []                                        |
| member_users                  | List of LDAP users with access to cluster.                   | []                                        |
| member_groups                 | List of LDAP groups with access to cluster.                  | []                                        |

### Openstack

Configuration for openstack, besides these variables update `cluster.json` as well.

| name                          | description                                                 | default value            |
| ----------------------------- | ----------------------------------------------------------- | ------------------------ |
| openstack_url                 | OpenStack URL (1)                                           |                          |
| openstack_credential_id       | Openstack credentials (1)                                   |                          |
| openstack_credential_secret   | Openstack credentials (1)                                   |                          |
| openstack_external_net        | OpenStack external network                                  | ext-net                  |
| openstack_security_kubernetes | IP address to allow connections to kube api port (2)        | { "world": "0.0.0.0/0" } |
| openstack_security_talos      | IP address to allow connections to talos api port (2)       | { "world": "0.0.0.0/0" } |
| openstack_network_cidr        | CIDR to be used for internal network                        | 192.168.0.0/21           |
| openstack_dns_servers         | DNS Servers                                                 | ["1.1.1.1", "8.8.8.8" ]  |
| openstack_floating_ip         | Number of floating IP addresses available for loadbalancers | 2                        |

### Talos

Specify the version of talos (make sure the image exists with this version) and kubernetes to use.

| name                          | description                                                  | default value                             |
| ----------------------------- | ------------------------------------------------------------ | ----------------------------------------- |
| talos_version                 | Image with most recent talos release                         | v1.5.5                                    |
| kubernetes_version            | Kubernetes version to install                                | v1.28.4                                   |

### Rancher

Connect to rancher for user management

| name               | description                                                  | default value |
| ------------------ | ------------------------------------------------------------ | ------------- |
| rancher_url        | URL where rancher runs (1)                                   |               |
| rancher_token      | Access token for rancher, clusters are created as this user (1) |               |
| user_principal_id  | User ID for rancher user, ID is placeholder for the user     | ID            |
| group_principal_id | Group ID for rancher group, ID is placeholder for the group  | ID            |

### ArgoCD Server

Connect to argocd and create two apps-of-apps.

| name              | description                        | default value |
| ----------------- | ---------------------------------- | ------------- |
| argocd_server_url | URL for argocd server (1)          |               |
| argocd_auth_token | Argocd auth token (1)              |               |
| argocd_address    | Argocd ip address for firewall (1) |               |
| argocd_sync       | Should apps automatically sync     | true          |

### ArgoCD Infrastructure App

This is used to install common applications in the cluster (see below)

| name              | description                                            | default value |
| ----------------- | ------------------------------------------------------ | ------------- |
| sealedsecrets_enabled | Enable sealed secrets | true |
| nfs_servers | values for nfs servers | {} |
| cinder_enabled | Enable cinder storage | true |
| longhorn_replicas | Number of replicas, set this to 0 to disable longhorn | 0 |
| rancher_monitoring_enabled | Enable rancher monitoring | true |
| ingress_controller | Desired ingress controller (traefik, nginx) leave blank to disable | traefik |

### Traefik Configuration

Configuration values for Traefik ingress controller. Not used when using nginx as ingress controller.

| name              | description                                            | default value |
| ----------------- | ------------------------------------------------------ | ------------- |
| traefik_access_log | Should traefik enable access logs | false |
| traefik_storageclass | storageclass used by ingress controller | "" |
| traefik_ports | Additional ports to add to traefik | {} |
| traefik_acme_server | URL for the acme server | https://acme-v02.api.letsencrypt.org/directory |
| traefik_acme_email | Use the following email for cert messages | devops@example.com |

### ArgoCD User App

User application to be monitored and installed using argocd.

| name              | description                                            | default value |
| ----------------- | ------------------------------------------------------ | ------------- |
| apps_git_url | URL for git reposiory to pull root apps from  (1) |  |
| apps_git_username | Username to access the GIT repository (1) |  |
| apps_git_password | Password to access the GIT repository (1) |  |
| apps_git_path | Path to root apps in git repo | user |
| apps_git_revision | Revision of root apps to deploy | HEAD |

# ArgoCD / Infrastructure

ArgoCD is used to install some common applications that will make using the kubernetes cluster easier. You can configure some options and disable services. Some services require components from openstack and will need to be configured during the the creation of the nodes.

- **metallb** : This is used for the load balancer. This requires floating ips to be created during the setup in openstack and are passed to metallb. In openstack there will be a public floating ip address which is associated with a private address. All nodes will have these private ip addresses as allowed addresses. When metallb hands out the private ip address (and thus the public one) it needs to be able to answer ARP requests, this is why the allowed address pair is needed.
- **ingresscontroler** : This is used for ingress rules. There are currently two options, traefik and nginx. For the ingress controller to work it requires metallb since it will need a public ip address. It will use the first of the floating ip addresses requested from openstack. Traefik can be configured to requests SSL certs using letsencrypt. The other option is to use cert-manager.
- **cert-manager** : This is used to request SSL certificates for ingress routes. This can be used with either traefik or nginx and will be configured to use letsencrypt. If traefik is installed, it will install a helper to create a certificate request for all ingressroutes from traefik as well.
- **sealedsecrets** : Allows to encrypt and commit secrets to a git repository. Secrets and encrypted using kubeseal and the public key of the cluster, and are pushed to the cluster encrypted where they are decrypted as kubernetes secrets.
- **monitoring** : The prometheus/alertmanager/grafana stack as configured by rancher. This allows it to plug into the rancher software and create the dashboards shown in rancher. This will also play nice with lens to view the cluster and statistics on a per pod/node basis.
- **nfs** : This will configure the nfs provisioner to run in the cluster, this is a RWX filesystem (can be used by multiple pods). This should be used to host large files. This should **NOT** be used to host databases (postgresql, mysql, sqlite). Multiple nfs servers can be configured as map.
- **cinder** : This requires the openstack credential-id and credential-secret to create volumes in openstack. The volumes will be RWO only volumes (can only be used by a single pod).
- **longhorn** : This will use left over diskspace in the cluster to create a shared filesystem. If using volumes hosted in cinder, keep in mind the default replication is 3, and you can end up using a lot of additional storage in openstack. The volumes created are both RWO and RWX.

Additionally to these infrastructure components, it can also configure argocd to read from a user controlled git repository where user defined applications can be hosted. Often this is used to install helm charts (using an app of apps) as well as raw kubernetes snippets.

# Upgrading talos/kubernetes

Once the cluster is created you need to upgrade the cluster using manual commands (if not it would destroy the kubernetes nodes).

Upgrade talos:

```
for n in $(talosctl get member -o json | jq -r '.spec.addresses[]'); do
  talosctl upgrade --wait --debug --preserve --node $n 
done
```

Upgrade kubernetes

```
talosctl upgrade-k8s --to 1.27.8
```

# TODO

- [ ] Setup ACME for traefik, needs to be `{}` when using cert-manager (harcoded right now).
- [ ] Find ways to prevent argocd/traefik dashboard from ending with an error while waiting.

