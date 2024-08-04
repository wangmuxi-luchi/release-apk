#!/bin/bash

hub checkout ${GIT_REPO}
git config --global --add safe.directory /github/workspace
VERSION_NUMBER=`grep -oP '"version": "\K(.*?)(?=")' ./package.json`
PROJECT_NAME=`grep -oP '"name": "\K(.*?)(?=")' ./package.json`
APK_FILES=(./${APP_FOLDER}/build/outputs/apk/release/*.apk)
if [ -f "${APK_FILES[0]}" ]; then
    # Rename the 'app-' part with ${PROJECT_NAME}_${VERSION_NUMBER}_
    for f in "${APK_FILES[@]}"; do
        STRING=${PROJECT_NAME}_${VERSION_NUMBER}_
        rename 's/app-/'"$STRING"'/' "$f"
    done
    # Replace the - with _
    for f in "${APK_FILES[@]}"; do
        rename 's/-/_/' "$f"
    done
    hub release edit -a ./${APP_FOLDER}/build/outputs/apk/release/*.apk -m "" v${VERSION_NUMBER}
fi

AAB_FILES=(./${APP_FOLDER}/build/outputs/bundle/release/*.aab)
if [ -f "${AAB_FILES[0]}" ]; then
    # Rename the 'app-' part with ${PROJECT_NAME}_${VERSION_NUMBER}_
    for f in "${AAB_FILES[@]}"; do
        STRING=${PROJECT_NAME}_${VERSION_NUMBER}_
        rename 's/app-/'"$STRING"'/' "$f"
    done
    # Replace the - with _
    for f in "${AAB_FILES[@]}"; do
        rename 's/-/_/' "$f"
    done
    hub release edit -a ./${APP_FOLDER}/build/outputs/bundle/release/*.aab -m "" v${VERSION_NUMBER}
fi
