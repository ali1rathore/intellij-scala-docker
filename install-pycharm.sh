#!/bin/bash

# Installs pycharm
ENV PYCHARM /opt/pycharm
RUN mkdir $PYCHARM
RUN wget https://download.jetbrains.com/python/pycharm-professional-2017.1.2.tar.gz -O - | tar xzv --strip-components=1 -C $PYCHARM
ENV PATH $PYCHARM/bin:$PATH
echo "Successfully installed pycharm in ${PYCHARM}"
