#!/bin/sh -e
cnt=$(buildah from --name esplinux/bootstrap scratch)
mnt=$(buildah mount esplinux/bootstrap)
echo cnt=$cnt
echo mnt=$mnt
tar xf musl-*.tgz -C $mnt
tar xf toybox-*.tgz -C $mnt
tar xf dash-*.tgz -C $mnt
buildah unmount $cnt
buildah commit esplinux/bootstrap esplinux/bootstrap
buildah containers
buildah images
