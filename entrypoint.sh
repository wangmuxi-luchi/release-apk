#!/bin/bash

hub checkout ${GIT_REPO}
git config --global --add safe.directory /github/workspace
VERSION_NUMBER=`grep -oP '"version": "\K(.*?)(?=")' ./package.json`
hub release edit -a ./${APP_FOLDER}/build/outputs/apk/release/**.apk -m "" v${VERSION_NUMBER}
hub release edit -a ./${APP_FOLDER}/build/outputs/bundle/release/**.aab -m "" v${VERSION_NUMBER}
