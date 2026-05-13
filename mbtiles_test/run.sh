#!/bin/bash

# 获取脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 根据之前的编译结果，构建目录位于源码目录的并列位置
# 源码: /home/lixiang/Documents/opensource/maplibre-native-qt
# 构建: /home/lixiang/Documents/opensource/build/qt6-Linux-OpenGL
BUILD_DIR="/home/lixiang/Documents/opensource/build/qt6-Linux-OpenGL"

# 如果硬编码路径不存在，尝试在父目录寻找
if [ ! -d "$BUILD_DIR" ]; then
    BUILD_DIR="$(dirname $(dirname "$SCRIPT_DIR"))/build/qt6-Linux-OpenGL"
fi

# 设置 Qt 环境
export QT_ROOT_DIR=/home/lixiang/Qt/6.5.3/gcc_64
export PATH=$QT_ROOT_DIR/bin:$PATH
# 设置库搜索路径 (核心库, Location 库, Quick 库)
export LD_LIBRARY_PATH=$BUILD_DIR/src/core:$BUILD_DIR/src/location:$BUILD_DIR/src/quick:$LD_LIBRARY_PATH

# 插件父目录
LOCATION_PLUGIN_PATH="$BUILD_DIR/src/location/plugins"
QUICK_PLUGIN_PATH="$BUILD_DIR/src/quick/plugins"

# QML 需要指向包含模块文件夹的父目录
export QML_IMPORT_PATH="$LOCATION_PLUGIN_PATH:$QUICK_PLUGIN_PATH:$QML_IMPORT_PATH"
export QT_PLUGIN_PATH="$LOCATION_PLUGIN_PATH:$QT_PLUGIN_PATH"

echo "--- Debug Info ---"
echo "BUILD_DIR: $BUILD_DIR"
if [ ! -d "$BUILD_DIR" ]; then
    echo "错误: 找不到构建目录 $BUILD_DIR"
    exit 1
fi
echo "QML_IMPORT_PATH: $QML_IMPORT_PATH"
echo "Checking for qmldir files:"
find "$LOCATION_PLUGIN_PATH" -name "qmldir" 2>/dev/null
find "$QUICK_PLUGIN_PATH" -name "qmldir" 2>/dev/null
echo "------------------"

# 检查 MBTiles 文件路径参数
if [ -z "$1" ]; then
    echo "使用方法: ./run.sh <mbtiles文件路径> [图层名称]"
    exit 1
fi

MBTILES_PATH=$(readlink -f "$1")
SOURCE_LAYER=${2:-"water"}

echo "正在加载: $MBTILES_PATH"
echo "尝试图层: $SOURCE_LAYER"

sed -i "s|readonly property string mbtilesPath:.*|readonly property string mbtilesPath: \"$MBTILES_PATH\"|" "$SCRIPT_DIR/main.qml"
sed -i "s|readonly property string mbtilesSrcLayer:.*|readonly property string mbtilesSrcLayer: \"$SOURCE_LAYER\"|" "$SCRIPT_DIR/main.qml"

# 启用详细日志
export QT_LOGGING_RULES="qt.location.*=true;qt.network.*=true;maplibre.*=true"
export QML_IMPORT_TRACE=1

# 启用图形调试信息
export QSG_INFO=1

# 使用 GLX 整合 (对 NVIDIA 驱动通常最稳定)
export QT_XCB_GL_INTEGRATION=xcb_glx
export QSG_RENDER_LOOP=basic
export QSG_RHI_BACKEND=opengl

echo "使用运行器: $RUNNER"
# 确保使用的是我们指定的 Qt 版本中的 qml 工具
$QT_ROOT_DIR/bin/qml "$SCRIPT_DIR/main.qml"
