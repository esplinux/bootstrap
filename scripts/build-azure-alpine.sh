#!/bin/sh -e

cnt=$(buildah from alpine:edge)
buildah run $cnt -- sh -c "echo 'http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories"
buildah run $cnt apk add bash sudo nodejs
buildah config --label com.azure.dev.pipelines.agent.handler.node.path=/usr/bin/node $cnt
buildah config --cmd node $cnt
buildah commit --squash $cnt esplinux/alpine-azurepipeline

# push with buildah push -f docker esplinux/alpine-azurepipeline docker://docker.io/esplinux/alpine-azurepipeline
