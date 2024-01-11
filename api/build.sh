#!/bin/bash

#!/bin/bash

# Check if Docker is running
if ! docker info &> /dev/null; then
  echo "Docker is not running."
  say "Docker is not running."
  exit 1
fi

echo "Docker is running."


# login
aws ecr get-login-password --region "$3" | docker login --username AWS --password-stdin "$4.dkr.ecr.$3.amazonaws.com"

# build name
BUILD_NAME="$1:$2"

echo "Building $BUILD_NAME"

# build the Docker image
docker build --platform linux/amd64 -t $BUILD_NAME .;


# tag the image
docker tag $BUILD_NAME "$4.dkr.ecr.$3.amazonaws.com/$BUILD_NAME"

# push the image
docker push "$4.dkr.ecr.$3.amazonaws.com/$BUILD_NAME"