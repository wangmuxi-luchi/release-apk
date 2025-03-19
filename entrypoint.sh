#!/bin/bash

hub checkout ${GIT_REPO}
git config --global --add safe.directory /github/workspace

echo "当前工作目录路径："
pwd

echo "输出环境变量GITHUB_REF：${GITHUB_REF}"

echo "当前目录${APP_FOLDER}文件夹下的文件和文件夹列表："
ls -la ./${APP_FOLDER}/

echo "设置release的版本号"
if [[ "$GITHUB_REF" == refs/tags/* ]]; then
    echo "当前引用是一个标签（tag）: $GITHUB_REF"
    TAG_NAME=${GITHUB_REF#refs/tags/}  # 提取标签名称
    echo "标签名称: $TAG_NAME"
    VERSION_NUMBER=$TAG_NAME
else
    echo "当前引用不是一个标签（tag）: $GITHUB_REF"
    VERSION_NUMBER=$(grep -oP 'versionName.*?"\K(.*?)(?=")' ./${APP_FOLDER}/build.gradle.*)
fi

FILE_PATH="./${APP_FOLDER}/build.gradle.*"
echo "在文件：${FILE_PATH}中检测项目名称 (applicationId)"
if ls ${FILE_PATH} 1> /dev/null 2>&1; then
    echo "文件${FILE_PATH}存在"
    ls ${FILE_PATH}
    PROJECT_NAME=$(grep -oP 'applicationId.*?"\K(.*)(?=(\.))\.\K(.*?)(?=")' ./${APP_FOLDER}/build.gradle.*)
else
    echo "没有找到匹配的文件:${FILE_PATH}"
    PROJECT_NAME="APP"
fi

echo "版本号 (versionName): ${VERSION_NUMBER}"
echo "项目名称 (applicationId): ${PROJECT_NAME}"

# VERSION_NUMBER=`grep -oP '"version": "\K(.*?)(?=")' ./package.json`
# PROJECT_NAME=`grep -oP '"name": "\K(.*?)(?=")' ./package.json`
APK_FILES=(./${APP_FOLDER}/build/outputs/apk/release/**.apk)
for file in ./${APP_FOLDER}/build/outputs/apk/release/*; do
    echo files before rename
    echo "$file"
done
if [ -f "${APK_FILES[0]}" ]; then
    # Rename the 'app-' part with ${PROJECT_NAME}_${VERSION_NUMBER}_
    for f in "${APK_FILES[@]}"; do
        STRING=${PROJECT_NAME}_${VERSION_NUMBER}_
        rename 's/app-/'"$STRING"'/' "$f"
    done
    # Replace the - with _ in the changed file names
    CHANGED_APK_FILES=(./${APP_FOLDER}/build/outputs/apk/release/**.apk)
    for f in "${CHANGED_APK_FILES[@]}"; do
        rename 's/-/_/' "$f"
    done

    for file in ./${APP_FOLDER}/build/outputs/apk/release/*; do
        echo files after rename
        echo "$file"
    done

    if hub release edit -a ./${APP_FOLDER}/build/outputs/apk/release/**_release.apk -m "" v${VERSION_NUMBER}; then
        echo added APK release
    else
        # if the release doesn't exist then create it
        echo created APK release
        hub release create -a ./${APP_FOLDER}/build/outputs/apk/release/**_release.apk -m "v${VERSION_NUMBER}" v${VERSION_NUMBER}
    fi
fi

AAB_FILES=(./${APP_FOLDER}/build/outputs/bundle/release/**.aab)
if [ -f "${AAB_FILES[0]}" ]; then
    # Rename the 'app-' part with ${PROJECT_NAME}_${VERSION_NUMBER}_
    for f in "${AAB_FILES[@]}"; do
        STRING=${PROJECT_NAME}_${VERSION_NUMBER}_
        rename 's/app-/'"$STRING"'/' "$f"
    done
    # Replace the - with _ in the changed file names
    CHANGED_AAB_FILES=(./${APP_FOLDER}/build/outputs/bundle/release/**.aab)
    for f in "${CHANGED_AAB_FILES[@]}"; do
        rename 's/-/_/' "$f"
    done
    if hub release edit -a ./${APP_FOLDER}/build/outputs/bundle/release/**_release.aab -m "" v${VERSION_NUMBER}; then 
        echo added AAB release
    else
        echo created AAB release
        hub release create -a ./${APP_FOLDER}/build/outputs/bundle/release/**_release.aab -m "v${VERSION_NUMBER}" v${VERSION_NUMBER}
    fi
fi
