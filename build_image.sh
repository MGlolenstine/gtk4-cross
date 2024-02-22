#!/usr/bin/env bash
set -euo pipefail

GTK=${GTK:-"main"}
ADW=${ADW:-"main"}
BASE=${BASE:-"gtk4-cross-base-$GTK-$ADW"}

if [[ $1 == "base" ]]; then
    echo "Building base image"
    IMAGE="gtk4-cross-base-hub"
elif [[ $1 == "rust" ]]; then
    echo "Building rust image"
    IMAGE="gtk4-cross-rust"
else
    echo "Currently allowed images are 'base' and 'rust'.";
    exit 0
fi

# Set a name for the newly built image.
TAG=${TAG:-"$IMAGE-$GTK-$ADW"}

mkdir -p "tmp/$IMAGE"
cp -rL "$IMAGE" "tmp/"
# Replace the remote image with  a local base.
sed -i "s/FROM mglolenstine\/gtk4-cross:%GTKTAG%/FROM $BASE/g" "tmp/$IMAGE/Dockerfile"
# Replace GTK and Adwaita versions.
sed -i "s/%GTKTAG%/$GTK/g" "tmp/$IMAGE/Dockerfile" && sed -i "s/%ADWTAG%/$ADW/g" "tmp/$IMAGE/Dockerfile"

cd "tmp/$IMAGE" || exit
# Start the image build.
docker build . -t "$TAG"
# Clean up the tmp directory.
rm -rf "tmp/$IMAGE"