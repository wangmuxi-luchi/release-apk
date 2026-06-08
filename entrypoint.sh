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
    # echo "标签名称: $TAG_NAME"
    # 使用正则表达式提取除了v以外的部分
    # TAG_NAME=${TAG_NAME#v}
else
    echo "当前引用不是一个标签（tag）: $GITHUB_REF"
    VERSION_NUMBER=$(grep -oP 'versionName.*?"\K(.*?)(?=")' ./${APP_FOLDER}/build.gradle.*)
    TAG_NAME="v${VERSION_NUMBER}"
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

echo "tag (tagName): ${TAG_NAME}"
echo "项目名称 (applicationId): ${PROJECT_NAME}"
echo "触发类型 (TRIGGER_TYPE): ${TRIGGER_TYPE}"

SUFFIX=""
RELEASE_TAG="${TAG_NAME}"
if [[ "$TRIGGER_TYPE" == *"test"* ]]; then
    SUFFIX="_test"
    RELEASE_TAG="${TAG_NAME}_test_$(date +%Y%m%d_%H%M%S)"
    echo "测试版本，添加测试后缀: ${SUFFIX}"
    echo "测试版本使用独立 tag: ${RELEASE_TAG}"
else
    echo "正式版本，使用正式命名"
fi

APK_FILES=(./${APP_FOLDER}/build/outputs/apk/release/**.apk)
for file in ./${APP_FOLDER}/build/outputs/apk/release/*; do
    echo files before rename
    echo "$file"
done
if [ -f "${APK_FILES[0]}" ]; then
    # Rename the 'app-' part with ${PROJECT_NAME}_${TAG_NAME}_
    for f in "${APK_FILES[@]}"; do
        STRING=${PROJECT_NAME}_${TAG_NAME}${SUFFIX}_
        rename 's/app-/'"$STRING"'/' "$f"
    done
    CHANGED_APK_FILES=(./${APP_FOLDER}/build/outputs/apk/release/**.apk)
    for f in "${CHANGED_APK_FILES[@]}"; do
        rename 's/-/_/' "$f"
    done

    for file in ./${APP_FOLDER}/build/outputs/apk/release/*; do
        echo files after rename
        echo "$file"
    done

    if hub release edit -a ./${APP_FOLDER}/build/outputs/apk/release/**_release.apk -m "" ${RELEASE_TAG}; then
        echo added APK release
    else
        echo created APK release
        hub release create -a ./${APP_FOLDER}/build/outputs/apk/release/**_release.apk -m "${RELEASE_TAG}" ${RELEASE_TAG}
    fi
fi

AAB_FILES=(./${APP_FOLDER}/build/outputs/bundle/release/**.aab)
if [ -f "${AAB_FILES[0]}" ]; then
    # Rename the 'app-' part with ${PROJECT_NAME}_${TAG_NAME}_
    for f in "${AAB_FILES[@]}"; do
        STRING=${PROJECT_NAME}_${TAG_NAME}${SUFFIX}_
        rename 's/app-/'"$STRING"'/' "$f"
    done
    CHANGED_AAB_FILES=(./${APP_FOLDER}/build/outputs/bundle/release/**.aab)
    for f in "${CHANGED_AAB_FILES[@]}"; do
        rename 's/-/_/' "$f"
    done
    if hub release edit -a ./${APP_FOLDER}/build/outputs/bundle/release/**_release.aab -m "" ${RELEASE_TAG}; then 
        echo added AAB release
    else
        echo created AAB release
        hub release create -a ./${APP_FOLDER}/build/outputs/bundle/release/**_release.aab -m "${RELEASE_TAG}" ${RELEASE_TAG}
    fi
fi