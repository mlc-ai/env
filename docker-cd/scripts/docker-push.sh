#!/bin/bash
set -e
set -x
set -u
set -o pipefail

TAG=$1
PLATFORM=$2

docker tag package-$PLATFORM mlcaidev/package-$PLATFORM:$TAG
docker push mlcaidev/package-$PLATFORM:$TAG
