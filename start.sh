#!/bin/bash
set -e

IMAGE=intellij-scala
[[ ! -z "$NAME" ]] || NAME=intellij
CODE=/Users/dev/
IP=$(ifconfig en0 inet | grep inet | awk '{print $2'})

open -a XQuartz
xhost + $IP

docker run -it -d \
        --name ${NAME} \
	-v ${CODE}:/home/developer/code \
	-v /tmp/.X11-unix:/tmp/.X11-unix \
	-e DISPLAY=${IP}:0.0 \
        -m 32g \
	${IMAGE} \
	/bin/bash 

echo "Container $NAME of image $IMAGE started"
