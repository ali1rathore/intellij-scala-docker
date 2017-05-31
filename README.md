# Docker image containing Intellij Idea with Scala plugin and SBT

1. First time

    Build the image:

        docker build -t intellij-scala .

    If you are using OSX:
        
      ensure latest XQuartz is installed (for X11 forwarding of Intellij), then

         export IP=$(ifconfig en0 inet | grep inet | awk '{print $2'})
         export DISPLAY=${IP}:0.0
         open -a XQuartz
         xhost + $IP
    
    Run the container and mount useful volumes
      (1) your source code that you'll edit with intellij
      (2) the container's home directory so build artifacts are cached on host

        export CODE=/path/to/source/code/on/host # location of source code
        export WORKDIR=/code  # working-directory inside of container 
        export CACHE_DIR=${CODE}/intellij_cache

        docker run -it \
               -e DISPLAY=${DISPLAY} \
               -w ${WORKDIR} \
               -v ${CODE}:${WORKDIR} \                    (1)
               -v ${CACHE_DIR}:/home/developer \          (2)
               -v /tmp/.X11-unix:/tmp/.X11-unix \
               --name intellij \
               intellij-scala \
               intellij

2. The next time

    docker start intellij
