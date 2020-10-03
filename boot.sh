#!/bin/bash

export APP_NAME=bigbang
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

	docker network connect $NETWORK registry.localhost
}

launch_k3d() {
    echo "creating cluster $APPNAME"
    echo `pwd`
	k3d cluster create $APP_NAME \
		-v `pwd`/registries.yaml:/etc/rancher/k3s/registries.yaml \
		-p 80:80@loadbalancer \
		-p 443:443@loadbalancer \
		--servers 1 \
		--agents 3

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
      ;;
    -d|--local-down)
      demolish_docker_registry
      demolish_k3d
      ;;
esac; shift; done
