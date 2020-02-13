#!/bin/sh -xe

CONTAINER_NAME="${CONTAINER_NAME:-esplinux/test}"
CMD="${CMD:-sh}"
TOP=$(pwd)

echo Building container $CONTAINER_NAME CMD $CMD

buildah --storage-driver=vfs --name $CONTAINER_NAME from scratch
mnt=$(buildah --storage-driver=vfs mount $CONTAINER_NAME)
cd $mnt
for tarball in "$@"
do
  tar xf $TOP/$tarball-*.tgz
done
buildah --storage-driver=vfs unmount $CONTAINER_NAME
buildah --storage-driver=vfs config --cmd $CMD $CONTAINER_NAME

# Hack label for Azure Pipelines into all containers
buildah --storage-driver=vfs config --label com.azure.dev.pipelines.agent.handler.node.path=/usr/local/bin/node $CONTAINER_NAME

buildah --storage-driver=vfs commit --squash $CONTAINER_NAME $CONTAINER_NAME
