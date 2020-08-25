#!/bin/bash

docker build --build-arg CLJSTYLE_VERSION=$VERSION -t $REPO .
