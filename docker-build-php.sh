#!/bin/bash

set -eEuo pipefail

declare -r DST_IMAGE=$1

declare -r VERSION_PHP=$2

declare -r VERSION_ALPINE=$3

# I could create a placeholder like php:x.y-image-alpinex.y in the Dockerfile itself,
# but I think it wouldn't be a good experience if you try to build the image yourself
# thus that's the way I opted to have dynamic base images
declare -r IMAGE_ORIGINAL_TAG="7.[0-9]-zts-alpine3.10]"

declare -r IMAGE_TAG="${VERSION_PHP}-alpine${VERSION_ALPINE}"
declare -r PHPAPICLIENTS_TAG="phpapiclients/github-cli:latest"

declare -r TAG_FILE="./tmp/build.tags"

sed -E "s/${IMAGE_ORIGINAL_TAG}/${IMAGE_TAG}/g" "Dockerfile" | docker build --no-cache --pull -t "${PHPAPICLIENTS_TAG}" --target="${DST_IMAGE}" -f - . \
    && echo "$PHPAPICLIENTS_TAG" >> "$TAG_FILE"
