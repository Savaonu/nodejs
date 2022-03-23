#!/bin/bash
# Deploy image to DockerHub

echo "tatabanilor123" | docker login -u "savaonu" --password-stdin

docker tag nodejs_image:latest savaonu/nodejs

docker push savaonu/nodejs