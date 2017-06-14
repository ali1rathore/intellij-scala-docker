FROM openjdk:8

MAINTAINER Ali R "github.com/ali--"

# Configures operative system dependencies
ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true
RUN apt-get update && \
    echo 'Installing OS dependencies' && \
    apt-get install -y --fix-missing sudo software-properties-common git libxext-dev libxrender-dev libxslt1.1 \
        libxtst-dev libgtk2.0-0 libcanberra-gtk-module unzip wget && \
    echo 'Cleaning up' && \
    apt-get clean -qq -y && \
    apt-get autoclean -qq -y && \
    apt-get autoremove -qq -y &&  \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

# Create the developer user
RUN echo 'Creating user: developer' && \
    mkdir -p /home/developer && \
    echo "developer:x:1000:1000:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
    echo "developer:x:1000:" >> /etc/group && \
    sudo echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
    sudo chmod 0440 /etc/sudoers.d/developer && \
    sudo chown developer:developer -R /home/developer && \
    sudo chown developer:developer -R /opt && \
    sudo chown developer:developer -R /usr/local/ && \
    sudo chown root:root /usr/bin/sudo && \
    chmod 4755 /usr/bin/sudo

# Scala expects this file
RUN touch /usr/lib/jvm/java-8-openjdk-amd64/release

USER developer
ENV HOME /home/developer
WORKDIR /home/developer

# Installs scala
ENV SCALA_VERSION 2.11.8
ENV SBT_VERSION 0.13.11
ENV SCALA_HOME /usr/local/share/scala
ENV SCALA_URL http://downloads.lightbend.com/scala
ENV SCALA_FILE scala-$SCALA_VERSION
ENV SCALA_TGZ $SCALA_FILE.tgz

RUN wget $SCALA_URL/$SCALA_VERSION/$SCALA_TGZ && \
	tar xvzf $SCALA_TGZ && \
	mv $SCALA_FILE "${SCALA_HOME}"

# Installs sbt
ENV SBT_URL https://dl.bintray.com/sbt/native-packages/sbt
ENV SBT_FILE sbt-$SBT_VERSION
ENV SBT_TGZ $SBT_FILE.tgz

RUN wget $SBT_URL/$SBT_VERSION/$SBT_TGZ && \
	tar xvzf $SBT_TGZ && \
	mv sbt $SCALA_HOME/sbt 

ENV PATH $SCALA_HOME/bin:$SCALA_HOME/sbt/bin:$PATH

ENV SBT_STUFF /sbt_stuff/.sbt
VOLUME  ["/sbt_stuff"]

RUN alias sbt="sbt -Dsbt.boot.directory=${SBT_STUFF}/boot -Dsbt.ivy.home=${SBT_STUFF}/.ivy2"

RUN sbt

# add scripts to install intellij and plugins
ADD ./install_intellij.sh /usr/local/bin/install_intellij.sh
ADD ./start_intellij.sh /usr/local/bin/intellij

