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

RUN echo 'Creating user: developer' && \
    mkdir -p /home/developer && \
    echo "developer:x:1000:1000:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
    echo "developer:x:1000:" >> /etc/group && \
    sudo echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
    sudo chmod 0440 /etc/sudoers.d/developer && \
    sudo chown developer:developer -R /home/developer && \
    sudo chown root:root /usr/bin/sudo && \
    chmod 4755 /usr/bin/sudo


# Installs scala
ENV SCALA_VERSION 2.11.8
ENV SBT_VERSION 0.13.11
ENV SCALA_HOME /usr/local/share/scala
ENV SCALA_URL http://downloads.lightbend.com/scala
ENV SCALA_FILE scala-$SCALA_VERSION
ENV SCALA_TGZ $SCALA_FILE.tgz

# Scala expects this file
RUN touch /usr/lib/jvm/java-8-openjdk-amd64/release

RUN wget $SCALA_URL/$SCALA_VERSION/$SCALA_TGZ && \
	tar xvzf $SCALA_TGZ && \
	mv $SCALA_FILE "${SCALA_HOME}"

# Installs intellij idea and plugins
ENV IDEA_MAJOR 2017.1
ENV IDEA_MINOR 3

RUN mkdir -p /home/developer/.IdeaIC$IDEA_MAJOR/config/options && \
    mkdir -p /home/developer/.IdeaIC$IDEA_MAJOR/config/plugins

ADD ./run /usr/local/bin/intellij

RUN chmod +x /usr/local/bin/intellij && \
    chown developer:developer -R /home/developer/.IdeaIC$IDEA_MAJOR

RUN echo 'Downloading IntelliJ IDEA' && \
    wget https://download-cf.jetbrains.com/idea/ideaIC-$IDEA_MAJOR.$IDEA_MINOR.tar.gz -O /tmp/intellij.tar.gz && \
    echo 'Installing IntelliJ IDEA' && \
    mkdir -p /opt/intellij && \
    tar -xf /tmp/intellij.tar.gz --strip-components=1 -C /opt/intellij && \
    rm /tmp/intellij.tar.gz

RUN echo 'Installing Scala plugin' && \
    wget 'https://plugins.jetbrains.com/plugin/download?updateId=32268' -O /home/developer/.IdeaIC$IDEA_MAJOR/config/plugins/scala.zip -q && \
    cd /home/developer/.IdeaIC$IDEA_MAJOR/config/plugins/ && \
    unzip -q scala.zip && \
    rm scala.zip

# Installs sbt
ENV SBT_URL https://dl.bintray.com/sbt/native-packages/sbt
ENV SBT_FILE sbt-$SBT_VERSION
ENV SBT_TGZ $SBT_FILE.tgz

RUN wget $SBT_URL/$SBT_VERSION/$SBT_TGZ && \
	tar xvzf $SBT_TGZ && \
	mv sbt $SCALA_HOME/sbt 

RUN sudo chown developer:developer -R /home/developer

USER developer
ENV HOME /home/developer
ENV PATH $SCALA_HOME/bin:$SCALA_HOME/sbt/bin:$PATH
WORKDIR /home/developer

RUN $SCALA_HOME/sbt/bin/sbt

CMD /usr/local/bin/intellij
