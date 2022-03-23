#!/bin/bash
# Deploy image to DockerHub

echo $2 | docker login -u $1 --password-stdin

docker tag nodejs_image:latest savaonu/nodejs

docker push savaonu/nodejs