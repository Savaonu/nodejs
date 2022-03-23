#!/bin/bash
# Deploy image to DockerHub

echo $2 | docker login -u $1 --password-stdin

docker tag $3 $4

docker push $4