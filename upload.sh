#!/bin/sh

set -e

# We need to set the auth file location, otherwise skopeo will attempt to write to /run/containers.
export REGISTRY_AUTH_FILE=/tmp/skopeo-auth.json

# Ensure we have a registry and credentials.
if [ -z ${REGISTRY} ]; then
  echo 'Not uploading, `registry` is not set.'
  exit 0
fi

if [ -z ${USERNAME} ]; then
  echo 'Cannot upload, `username` is not set.'
  exit 1
fi;

if [ -z ${PASSWORD} ]; then
  echo 'Cannot upload, `password` is not set.'
  exit 1
fi;

if [ -z ${REPO_PATH} ]; then
  echo 'Cannot upload, `path` is not set.'
  exit 1
fi;

if [ -z ${INPUT_TAG} ]; then
  echo "`tag` is not set, determining automatically."
  if [ -z ${GITHUB_REF} ]; then
    echo "{{github.ref}} is not set; cannot automatically determine a tag."
    exit 1
  fi;

  if [ ${GITHUB_REF} = "refs/heads/main" ]; then
    TAG=latest
  elif [ ${GITHUB_REF} = "refs/heads/master" ]; then
    TAG=latest
  fi;

  # Otherwise we cut off the first two /-delimited fields, which we expect to be "refs/heads/".
  TAG=$(echo ${GITHUB_REF} | cut -d '/' -f 3-)

  echo "Ref ${GITHUB_REF} parsed to tag ${TAG}"
else
  TAG=${INPUT_TAG}
fi;

TARGET="${REGISTRY}/${REPO_PATH}:${TAG}"
IMAGE=$(readlink -f /tmp/nix-container-build)

echo "Logging in to ${REGISTRY}"
skopeo login --username "${USERNAME}" --password "${PASSWORD}" ${REGISTRY}

echo "Uploading ${IMAGE} to ${TARGET}"
echo skopeo --insecure-policy copy "docker-archive://${IMAGE}" "docker://${TARGET}"

# Log back out to at least not have credentials floating around on the filesystem.
skopeo logout ${REGISTRY}
