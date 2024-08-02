#!/bin/bash
hub checkout ${${REPO_BRANCH}}
VERSION_NAME=`grep -oP 'versionName "\K(.*?)(?=")' ./${APP_FOLDER}/build.gradle`
hub release create -a ./${APP_FOLDER}/build/outputs/apk/release/**.apk -m "v${GITHUB_REF##*/}" ${GITHUB_REF##*/} 
