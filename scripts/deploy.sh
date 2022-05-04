#!/usr/bin/env bash

# Login to docker hub
echo "DOCKER_PASSWORD" | docker login -u "DOCKER_USERNAME" --password-stdin
docker build -t kunihir0/papermc_arch:$PAPER_VERSION --build-arg PAPER_VERSION=$PAPER_VERSION --build-arg JAVA_VERSION=$JAVA_VERSION .
docker push kunihir0/papermc_arch:$PAPER_VERSION