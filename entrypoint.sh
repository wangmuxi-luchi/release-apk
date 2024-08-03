#!/bin/bash

hub checkout ${GIT_REPO}
git config --global --add safe.directory /github/workspace
VERSION_NUMBER=`grep -oP '"version": "\K(.*?)(?=")' ./package.json`
if [ -f ./${APP_FOLDER}/build/outputs/apk/release/**.apk ]; then
  hub release edit -a ./${APP_FOLDER}/build/outputs/apk/release/**.apk -m "" v${VERSION_NUMBER}
fi
if [ -f ./${APP_FOLDER}/build/outputs/bundle/release/**.aab ]; then
  hub release edit -a ./${APP_FOLDER}/build/outputs/bundle/release/**.aab -m "" v${VERSION_NUMBER}
fi
