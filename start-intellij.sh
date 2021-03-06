#!/usr/bin/env bash

function delayedPluginInstall {
    sudo mkdir -p /home/developer/.IdeaIC$IDEA_MAJOR/config/plugins
    sudo mkdir -p /home/developer/.IdeaIC$IDEA_MAJOR/config/options
    sudo chown developer:developer -R /home/developer/.IdeaIC$IDEA_MAJOR

    cd /home/developer/.IdeaIC$IDEA_MAJOR/config/plugins/

    echo 'Installing Scala plugin'
    wget https://plugins.jetbrains.com/files/1347/26538/scala-intellij-bin-3.0.8.zip -O scala.zip -q && unzip -q scala.zip && rm scala.zip

    # Adding the predefined preferences to IDEA
    cp /home/developer/.jdk.table.xml /home/developer/.IdeaIC$IDEA_MAJOR/config/options/jdk.table.xml
}

if [ ! -d /home/developer/.IdeaIC$IDEA_MAJOR/config/plugins/Scala ]; then
    # We are running with a non-Docker contained volume for IntelliJ prefs so we need to setup the plugin again
    delayedPluginInstall
fi

if [ -d /home/developer/.IdeaIC$IDEA_MAJOR ]; then
    # Ensure proper permissions
    sudo chown developer:developer -R /home/developer/.IdeaIC$IDEA_MAJOR
fi

exec /opt/intellij/bin/idea.sh
