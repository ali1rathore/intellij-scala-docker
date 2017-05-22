#!/bin/bash
set -e


IMAGE=intellij-scala
[[ ! -z "$NAME" ]] || NAME=intellij
IP=$(ifconfig en0 inet | grep inet | awk '{print $2'})

SNAP_DEV=/Users/dev/sparklinedata
SNAP=$SNAP_DEV/jupyterhub-k8s/user/snap

SPARK_VERSION=2.0.2
SPARK=/Users/dev/sparklinedata/spark-${SPARK_VERSION}

if [[ ! -d "$SPARK" ]]; then
    echo "Could not find spark installed at ${SPARK}, so I'll install it there"
    mkdir -p $SPARK
    wget http://d3kbcqa49mib13.cloudfront.net/spark-${SPARK_VERSION}-bin-hadoop2.7.tgz -O - | tar xvz --strip-components=1 -C $SPARK_HOME
fi

SPARK_HOME=/opt/spark
SNAP_HOME=/opt/snap

open -a XQuartz
xhost + $IP

docker run -it -d \
        --name ${NAME} \
        -p 4040:4040 \
        -p 10000:10000 \
        -v ${SPARK}:${SPARK_HOME} \
        -v ${SNAP}:${SNAP_HOME} \
	-v ${SNAP_DEV}:/home/developer/code \
	-v /tmp/.X11-unix:/tmp/.X11-unix \
	-e DISPLAY=${IP}:0.0 \
	${IMAGE} \
	/bin/bash 

echo "Container $NAME of image $IMAGE started"

#NB_NAME=nb NAME= intellijt docker run --name ${NB_NAME} --rm -d -it -v ${SNAP_DEV}:/home/jovyan -e NO_SPARK=true --link ${NAME} -p 8888:8888 snap start-notebook


