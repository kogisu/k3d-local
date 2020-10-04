#!/bin/bash

export APP_NAME=knockout
export NETWORK=k3d-${APP_NAME}

launch_docker_registry() {
	# create docker volume to store image layers
	docker volume create local_registry
  
	# run local docker registry instance
	docker container run -d \
		--name registry.localhost \
		-v local_host:/var/lib/registry \
		--restart always -p 5000:5000 \
		registry:2

    # add docker registry to network
	docker network connect $NETWORK registry.localhost
}

launch_k3d() {
    echo "creating cluster $APPNAME"
    echo `pwd`
	k3d cluster create $APP_NAME \
		-v `pwd`/registries.yaml:/etc/rancher/k3s/registries.yaml \
		-p 80:80@loadbalancer \
		-p 443:443@loadbalancer \
		--k3s-server-arg '--no-deploy=traefik' \
		--servers 1 \
		--agents 3
}

launch_argocd() {
    kubectl create namespace argocd
    kubectl apply -n argocd -f `pwd`/argo/argo.yaml
    kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

}

create_ingress_objects() {
    kubectl create namespace nginx
    kubectl apply -n nginx -f `pwd`/nginx/ingress.yaml
}

demolish_docker_registry() {
    docker stop registry.localhost
    docker rm registry.localhost
    docker volume rm local_registry
}
demolish_k3d() {
	k3d cluster delete $APP_NAME
}

echo "
Usage:
  ./boot.sh [flags]

Flags:
  -u --local-up     Bring up local cluster
  -d --local-down   Bring down local cluster
"

while [[ "$1" =~ ^- && ! "$1" == "--" ]]; do case $1 in
    -u|--local-up)
      launch_docker_registry
      launch_k3d
      launch_argocd
      ;;
    -d|--local-down)
      demolish_docker_registry
      demolish_k3d

      ;;
esac; shift; done
