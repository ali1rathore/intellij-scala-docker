FROM ubuntu:16.04

MAINTAINER Felipe Triana "ali--@gmail.com"

# Configures operative system dependencies
ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true
RUN sed 's/main$/main universe/' -i /etc/apt/sources.list && \
    apt-get update -qq && \
    echo 'Installing OS dependencies' && \
    apt-get install -qq -y --fix-missing sudo software-properties-common git libxext-dev libxrender-dev libxslt1.1 \
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


# Installs java
ENV JAVA_VERSION 8
ENV JAVA_UPDATE 72
ENV JAVA_BUILD 15
ENV JAVA_HOME /usr/lib/jvm/jdk1.${JAVA_VERSION}.0_${JAVA_UPDATE}
RUN apt-get update && apt-get install ca-certificates curl \
        gcc libc6-dev libssl-dev make \
        -y --no-install-recommends && \
	mkdir -p /usr/lib/jvm && \
	curl --silent --location --retry 3 --cacert /etc/ssl/certs/GeoTrust_Global_CA.pem \
	--header "Cookie: oraclelicense=accept-securebackup-cookie;" \
	http://download.oracle.com/otn-pub/java/jdk/"${JAVA_VERSION}"u"${JAVA_UPDATE}"-b"${JAVA_BUILD}"/server-jre-"${JAVA_VERSION}"u"${JAVA_UPDATE}"-linux-x64.tar.gz \
	| tar xz -C /usr/lib/jvm && \
    apt-get remove --purge --auto-remove -y \
            gcc \
            libc6-dev \
            libssl-dev \
            make && \
	apt-get autoclean && apt-get --purge -y autoremove && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV PATH $JAVA_HOME/bin:$PATH

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

# Installs intellij idea and plugins
ENV IDEA_MAJOR 2017.1
ENV IDEA_MINOR 3

RUN mkdir -p /home/developer/.IdeaIC$IDEA_MAJOR/config/options && \
    mkdir -p /home/developer/.IdeaIC$IDEA_MAJOR/config/plugins

ADD ./jdk.table.xml /home/developer/.IdeaIC$IDEA_MAJOR/config/options/jdk.table.xml
ADD ./jdk.table.xml /home/developer/.jdk.table.xml

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
    wget 'https://plugins.jetbrains.com/plugin/download?pr=idea&updateId=33637' -O /home/developer/.IdeaIC$IDEA_MAJOR/config/plugins/scala.zip -q && \
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
