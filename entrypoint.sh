#!/bin/bash

hub checkout ${GIT_REPO}
git config --global --add safe.directory /github/workspace
VERSION_NUMBER=`grep -oP '"version": "\K(.*?)(?=")' ./package.json`
hub release edit -a ./${APP_FOLDER}/build/outputs/apk/release/**.{aab,apk} -m "" v${VERSION_NUMBER}
