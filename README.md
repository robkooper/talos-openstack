# Talos, Rancher, Openstack Kubernetes Cluster

This repository contains the code to setup a Talos kubernetes cluster using Rancher, and ArgoCD on Openstack. It is assumed you already have Rancher and ArgoCD up and running. 

Once the cluster is running it will have an ingress controller, storge controllers and metallb loadbalancer. Users are added/removed through rancher for SSO.

## terraform

This folder contains the terraform to create the cluster on openstack. For the load balancer to work it will have the floating ip's associated with a private IP that is associated with each of the virtual machines. This will allow metallb to associate the floating ip's with the VM where the service is running and openstack will route the traffic to that server.

## infrastructure

This folder contains the argocd apps that take care of the infrastructure:

- **metallb** : This is used for the load balancer. This requires floating ips to be created during the setup in openstack and are passed to metallb. In openstack there will be a public floating ip address which is associated with a private address. All nodes will have these private ip addresses as allowed addresses. When metallb hands out the private ip address (and thus the public one) it needs to be able to answer ARP requests, this is why the allowed address pair is needed.
- **ingresscontroler** : This is used for ingress rules. There are currently two options, traefik and nginx. For the ingress controller to work it requires metallb since it will need a public ip address. It will use the first of the floating ip addresses requested from openstack. Traefik can be configured to requests SSL certs using letsencrypt. The other option is to use cert-manager.
- **cert-manager** : This is used to request SSL certificates for ingress routes. This can be used with either traefik or nginx and will be configured to use letsencrypt. If traefik is installed, it will install a helper to create a certificate request for all ingressroutes from traefik as well.
- **sealedsecrets** : Allows to encrypt and commit secrets to a git repository. Secrets and encrypted using kubeseal and the public key of the cluster, and are pushed to the cluster encrypted where they are decrypted as kubernetes secrets.
- **monitoring** : The prometheus/alertmanager/grafana stack as configured by rancher. This allows it to plug into the rancher software and create the dashboards shown in rancher. This will also play nice with lens to view the cluster and statistics on a per pod/node basis.
- **nfs** : This will configure the nfs provisioner to run in the cluster, this is a RWX filesystem (can be used by multiple pods). This should be used to host large files. This should **NOT** be used to host databases (postgresql, mysql, sqlite). Multiple nfs servers can be configured as map.
- **cinder** : This requires the openstack credential-id and credential-secret to create volumes in openstack. The volumes will be RWO only volumes (can only be used by a single pod).
- **longhorn** : This will use left over diskspace in the cluster to create a shared filesystem. If using volumes hosted in cinder, keep in mind the default replication is 3, and you can end up using a lot of additional storage in openstack. The volumes created are both RWO and RWX.

## user

This folder contains the user application, an example application `kubernetes` will read the kubernetes manifests in the kubernetes folder.

