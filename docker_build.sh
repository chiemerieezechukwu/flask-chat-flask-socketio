#!/bin/bash
set -xe

REPOSITORY_URI=$1
image_tag=$2
Dockerpath=$3
location=$4

aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin 095420315607.dkr.ecr.eu-central-1.amazonaws.com
DOCKER_DEFAULT_PLATFORM=linux/amd64 docker build -t $REPOSITORY_URI:$image_tag -f $Dockerpath $location
# docker tag $image_name:$image_tag $REPOSITORY_URI:latest
docker push  $REPOSITORY_URI:$image_tag