#!/bin/sh -e
cnt=$(buildah from --name esplinux/bootstrap scratch)
buildah containers
mnt=$(buildah mount esplinux/bootstrap)
echo cnt=$cnt
echo mnt=$mnt
buildah mount
buildah unmount $cnt
buildah mount
buildah containers
