#!/bin/bash

hub checkout ${GIT_REPO}
git config --global --add safe.directory /github/workspace
VERSION_NUMBER=`grep -oP '"version": "\K(.*?)(?=")' ./package.json`
PROJECT_NAME=`grep -oP '"name": "\K(.*?)(?=")' ./package.json`
if [ -f ./${APP_FOLDER}/build/outputs/apk/release/**.apk ]; then
    for f in ./${APP_FOLDER}/build/outputs/apk/release/**.apk; do
        STRING=${PROJECT_NAME}_${VERSION_NUMBER}_
        echo $STRING
        rename 's/app-/'+$STRING+'/' $f
    done
  hub release edit -a ./${APP_FOLDER}/build/outputs/apk/release/**.apk -m "" v${VERSION_NUMBER}
fi
if [ -f ./${APP_FOLDER}/build/outputs/bundle/release/**.aab ]; then
for f in ./${APP_FOLDER}/build/outputs/apk/release/**.aab; do
        STRING=${PROJECT_NAME}_${VERSION_NUMBER}_
        echo $STRING
        rename 's/app-/'+$STRING+'/' $f
    done
  hub release edit -a ./${APP_FOLDER}/build/outputs/bundle/release/**.aab -m "" v${VERSION_NUMBER}
fi
