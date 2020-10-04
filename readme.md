# k3d-local

Simple Bootstrap tool for deploying a mini k3s - based cluster in docker (k3d). The bootstrap script deploys a 3 - master, 1 node worker cluster for development of applications and integration in a kubernetes environment.  

## Requirements
### Docker
In order to deploy the cluster, the main requirement is to install Docker.  Currently the supported version for this install script is `docker version 19.03.0^`.  Currently installed version in creating this tool is `19.03.13`.  

### k3d
Install k3d locally 
- brew if using mac
- apt if using linux based distro | install binary directly on github [releases](https://github.com/rancher/k3d/releases)

Installed version:
```
$ k3d version
k3d version v3.0.2
k3s version latest (default)
```

## Setup
Setup using the cli bootstrap tool in the root directory.  From the root directory, run the following:
```
# Create the cluster 
$ ./boot.sh -u 

creating cluster 
/Users/kento/code/k3d
WARN[0000] No node filter specified                     
INFO[0000] Created network 'k3d-bigbang'                
INFO[0000] Created volume 'k3d-bigbang-images'          
INFO[0001] Creating node 'k3d-bigbang-server-0'         
INFO[0001] Creating node 'k3d-bigbang-agent-0'          
INFO[0002] Creating node 'k3d-bigbang-agent-1'          
INFO[0002] Creating node 'k3d-bigbang-agent-2'          
INFO[0003] Creating LoadBalancer 'k3d-bigbang-serverlb' 
INFO[0004] Cluster 'bigbang' created successfully!      
INFO[0005] You can now use it like this:                
kubectl cluster-info
namespace/argocd created
customresourcedefinition.apiextensions.k8s.io/applications.argoproj.io created
customresourcedefinition.apiextensions.k8s.io/appprojects.argoproj.io created
serviceaccount/argocd-application-controller created
serviceaccount/argocd-dex-server created
serviceaccount/argocd-server created
role.rbac.authorization.k8s.io/argocd-application-controller created
role.rbac.authorization.k8s.io/argocd-dex-server created
role.rbac.authorization.k8s.io/argocd-server created
clusterrole.rbac.authorization.k8s.io/argocd-application-controller created
clusterrole.rbac.authorization.k8s.io/argocd-server created
rolebinding.rbac.authorization.k8s.io/argocd-application-controller created
rolebinding.rbac.authorization.k8s.io/argocd-dex-server created
rolebinding.rbac.authorization.k8s.io/argocd-server created
clusterrolebinding.rbac.authorization.k8s.io/argocd-application-controller created
clusterrolebinding.rbac.authorization.k8s.io/argocd-server created
configmap/argocd-cm created
configmap/argocd-gpg-keys-cm created
configmap/argocd-rbac-cm created
configmap/argocd-ssh-known-hosts-cm created
configmap/argocd-tls-certs-cm created
secret/argocd-secret created
service/argocd-dex-server created
service/argocd-metrics created
service/argocd-redis created
service/argocd-repo-server created
service/argocd-server-metrics created
service/argocd-server created
deployment.apps/argocd-application-controller created
deployment.apps/argocd-dex-server created
deployment.apps/argocd-redis created
deployment.apps/argocd-repo-server created
deployment.apps/argocd-server created
namespace/nginx created
ingress.extensions/nginx created
deployment.apps/nginx created
service/nginx created

```
The above creates the k3d cluster, a private docker registry to pull images from for your cluster, and argocd resources for gitops deployments.  k3d defaults with a traefik based loadbalancer.  This will be removed from the default deployment and replaced with the argocd loadbalancer, which will be listening on ports `80` and `443`.  The loadbalancer will be port-forwarded to `localhost` using the `-p` flag in the `k3d cluster create` command.

## ArgoCD
ArgoCD is a gitops tool for making git the source of truth for kubernetes deployments.  To deploy applications in kubernetes through ArgoCD, an `application.yaml` file is created and applied to the cluster, which points to a git repo.  An example application is provided at [guestbook](https://gitlab.com/kogisu/guestbook).  

After creating the k3d cluster using the bootstrap cli, create a git repo (using github, gitlab) and add an `application.yaml` file as well as resources to deploy to kubernetes.  In the `guestbook` example, two resources are deployed: a `deployment` and a `service`.  

### UI
ArgoCD also provided a convenient UI tool for managing / monitoring the state of `argoCD` applications in the cluster. To access it, go to `localhost`.  The credentials are the following:
```
username: admin
password: <run following command>

$ kubectl get pods -n argocd -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2
```
The password defaults to the pod name of the argocd server.

## Sync Changes
ArgoCD automatically syncs changes to your cluster by pinging the git repository (and checks the `HEAD` commit).  After comming new changes to your repository, ArgoCD will sync the changes on your behalf.  To see your changes, make a commit to the repo tied to your `application.yaml` file.  