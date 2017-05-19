# Docker image containing Intellij Idea with Scala plugin and SBT

1. First time

    Build the image:

        docker build -t intellij-scala .
    
    Run the container:

        docker run -it -e DISPLAY=${DISPLAY} -v /tmp/.X11-unix:/tmp/.X11-unix --name intellij intellij-scala

        or 

        start.sh

2. The next time

    docker start intellij
