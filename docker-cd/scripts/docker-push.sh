#!/bin/bash
set -e
set -x
set -u
set -o pipefail

PLATFORM=$1

TAG=$(git log -1 --format='%h')
docker tag package-$PLATFORM mlcaidev/package-$PLATFORM:$TAG
docker push mlcaidev/package-$PLATFORM:$TAG
docker rmi mlcaidev/package-$PLATFORM:$TAG

if [ "$PLATFORM" != "cpu" ]; then
	docker rmi package-$PLATFORM
fi

docker system prune -f
docker image prune -f

docker images --all
docker ps -a
df -h
