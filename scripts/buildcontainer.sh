#!/bin/sh -xe

CONTAINER_NAME="${CONTAINER_NAME:-esplinux/test}"
CMD="${CMD:-sh}"
TOP=$(pwd)

echo Building container $CONTAINER_NAME CMD $CMD

buildah --name $CONTAINER_NAME from scratch
mnt=$(buildah unshare buildah mount $CONTAINER_NAME)
cd $mnt
for tarball in "$@"
do
  tar xf $TOP/$tarball-*.tgz
done
buildah unshare buildah unmount $CONTAINER_NAME
buildah config --cmd $CMD $CONTAINER_NAME

# Hack label for Azure Pipelines into all containers
buildah config --label com.azure.dev.pipelines.agent.handler.node.path=/usr/local/bin/node $CONTAINER_NAME

buildah commit $CONTAINER_NAME $CONTAINER_NAME

buildah images
buildah inspect $CONTAINER_NAME
