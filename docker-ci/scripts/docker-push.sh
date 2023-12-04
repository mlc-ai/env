#!/bin/bash
set -e
set -x
set -u
set -o pipefail

PLATFORM=$1

TAG=$(git log -1 --format='%h')
docker tag ci-$PLATFORM mlcaidev/ci-$PLATFORM:$TAG
docker push mlcaidev/ci-$PLATFORM:$TAG
docker rmi mlcaidev/ci-$PLATFORM:$TAG
docker rmi ci-$PLATFORM

docker system prune -f
docker image prune -f

docker images --all
docker ps -a
df -h
