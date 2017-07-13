#!/bin/bash

# Installs intellij idea and plugins
export IDEA_MAJOR=2017.1
export IDEA_MINOR=3
export INTELLIJ_INSTALL=/opt/intellij

if [[ -z "$HOME" ]]; then
    export HOME=/home/${USER}
    if ${USER} == "root"; then
        export HOME=/root
    fi
fi

mkdir -p ${HOME}/.IdeaIC$IDEA_MAJOR/config/options && \
mkdir -p ${HOME}/.IdeaIC$IDEA_MAJOR/config/plugins

cp ./run /usr/local/bin/intellij
chmod +x /usr/local/bin/intellij

chmod +x /usr/local/bin/intellij && \
    chown ${USER}:${USER} -R ${HOME}/.IdeaIC$IDEA_MAJOR

echo 'Downloading IntelliJ IDEA' && \
    wget https://download-cf.jetbrains.com/idea/ideaIC-$IDEA_MAJOR.$IDEA_MINOR.tar.gz -O /tmp/intellij.tar.gz && \
    echo 'Installing IntelliJ IDEA' && \
    mkdir -p ${INTELLIJ_INSTALL} && \
    tar -xf /tmp/intellij.tar.gz --strip-components=1 -C ${INTELLIJ_INSTALL} && \
    rm /tmp/intellij.tar.gz

RUN echo 'Installing Scala plugin' && \
    wget 'https://plugins.jetbrains.com/plugin/download?updateId=32268' -O ${HOME}/.IdeaIC$IDEA_MAJOR/config/plugins/scala.zip -q && \
    cd ${HOME}/.IdeaIC$IDEA_MAJOR/config/plugins/ && \
    unzip -q scala.zip && \
    rm scala.zip

echo "Successfully installed intellij in ${INTELLIJ_INSTALL}"
