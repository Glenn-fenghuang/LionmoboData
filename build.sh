#!/bin/bash

# 停止脚本遇到任何错误时
set -e

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 项目配置
WORKSPACE_PATH="$SCRIPT_DIR/LionmoboData.xcworkspace"
SCHEME="LionmoboData"
CONFIGURATION="Release"
DERIVED_DATA_DIR="$SCRIPT_DIR/../DerivedData"
FRAMEWORK_NAME="LionmoboData"

# 创建输出目录
mkdir -p ${DERIVED_DATA_DIR}/universal

# 编译真机架构
xcodebuild -configuration $CONFIGURATION -derivedDataPath ${DERIVED_DATA_DIR}/iOS -workspace $WORKSPACE_PATH -scheme $SCHEME -sdk iphoneos clean build

# 编译模拟器架构
xcodebuild -configuration $CONFIGURATION -derivedDataPath ${DERIVED_DATA_DIR}/simulator -workspace $WORKSPACE_PATH -scheme $SCHEME -sdk iphonesimulator clean build

# 创建XCFramework
xcodebuild -create-xcframework \
-framework ${DERIVED_DATA_DIR}/iOS/Build/Products/Release-iphoneos/${FRAMEWORK_NAME}.framework \
-framework ${DERIVED_DATA_DIR}/simulator/Build/Products/Release-iphonesimulator/${FRAMEWORK_NAME}.framework \
-output ${DERIVED_DATA_DIR}/universal/${FRAMEWORK_NAME}.xcframework

echo "Universal XCFramework is created at: ${DERIVED_DATA_DIR}/universal/${FRAMEWORK_NAME}.xcframework"

echo "-------------编译完成---------------------------"
