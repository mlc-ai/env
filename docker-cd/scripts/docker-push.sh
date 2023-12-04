#!/bin/bash
set -e
set -x
set -u
set -o pipefail

PLATFORM=$1

TAG=$(git log -1 --format='%h')
docker tag package-$PLATFORM mlcaidev/package-$PLATFORM:$TAG
docker push mlcaidev/package-$PLATFORM:$TAG
