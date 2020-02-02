#!/bin/sh -xe

CONTAINER_NAME="${CONTAINER_NAME:-esplinux/test}"
CMD="${CMD:-sh}"

echo Building container $CONTAINER_NAME CMD $CMD

mkdir rootfs
for tarball in "$@"
do
  tar xf $tarball-*.tgz -C rootfs
done

cd rootfs
tar -zcf ../rootfs.tgz .
cd ..

# Hack label for Azure Pipelines into all containers
podman import -c "CMD [\"$CMD\"]" -c 'LABEL com.azure.dev.pipelines.agent.handler.node.path=/usr/local/bin/node' rootfs.tgz $CONTAINER_NAME 
podman images
podman inspect $CONTAINER_NAME
rm -rf rootfs rootfs.tgz
