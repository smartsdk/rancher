#!/bin/bash
set -e

cd "$(dirname "$0")"

TAG=${TAG:-$(awk '/ENV CATTLE_RANCHER_SERVER_VERSION/{print $3}' Dockerfile)}
REPO=${REPO:-$(awk '/ENV CATTLE_RANCHER_SERVER_IMAGE/{print $3}' Dockerfile)}
IMAGE=${REPO}:${TAG}

docker build -t "${IMAGE}" .

cat > Dockerfile.master << EOF
FROM ${IMAGE}
ENV CATTLE_MASTER true
EOF
trap "rm Dockerfile.master" EXIT

docker build -t "${REPO}:master" -f Dockerfile.master .

echo Done building "${IMAGE}"
