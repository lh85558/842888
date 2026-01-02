#!/bin/bash
# TP842Nv3 LEDE 打印服务器固件构建脚本

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== TP842Nv3 LEDE 打印服务器固件构建脚本 ===${NC}"

# 检查系统
if ! grep -q "Ubuntu 22" /etc/os-release; then
    echo -e "${YELLOW}警告: 建议在Ubuntu 22.04 LTS上构建${NC}"
fi

# 安装依赖
echo -e "${GREEN}安装构建依赖...${NC}"
sudo apt update
sudo apt install -y \
    build-essential ccache ecj fastjar file g++ gawk \
    gettext git java-propose-classpath libelf-dev libncurses5-dev \
    libncursesw5-dev libssl-dev python python2.7-dev python3 unzip wget \
    python3-distutils python3-setuptools python3-dev rsync subversion \
    swig time xsltproc zlib1g-dev

# 创建工作目录
BUILD_DIR="openwrt-build"
if [ -d "$BUILD_DIR" ]; then
    echo -e "${YELLOW}清理旧的构建目录...${NC}"
    rm -rf "$BUILD_DIR"
fi

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# 克隆源码
echo -e "${GREEN}克隆OpenWrt源码...${NC}"
git clone https://gitcode.com/lh85558/openwrt.git openwrt
cd openwrt

# 更新和安装feed
echo -e "${GREEN}更新软件源...${NC}"
./scripts/feeds update -a
./scripts/feeds install -a

# 复制自定义文件
echo -e "${GREEN}应用自定义配置...${NC}"
if [ -d "../../files" ]; then
    cp -r ../../files/* ./
fi

# 应用diffconfig
if [ -f "../../diffconfig" ]; then
    cp ../../diffconfig .config
    make defconfig
else
    # 手动配置
    echo -e "${GREEN}手动配置目标...${NC}"
    make menuconfig
fi

# 下载源码
echo -e "${GREEN}下载源码包...${NC}"
make download -j$(nproc)

# 开始编译
echo -e "${GREEN}开始编译固件...${NC}"
make -j$(nproc) V=s

# 检查固件大小
FIRMWARE="bin/targets/ar71xx/generic/openwrt-ar71xx-generic-tl-wr842n-v3-squashfs-factory.bin"
if [ -f "$FIRMWARE" ]; then
    SIZE=$(stat -c%s "$FIRMWARE")
    SIZE_MB=$((SIZE / 1024 / 1024))
    echo -e "${GREEN}固件构建成功!${NC}"
    echo -e "${GREEN}固件大小: ${SIZE_MB}MB${NC}"
    
    if [ $SIZE_MB -gt 16 ]; then
        echo -e "${RED}警告: 固件大小超过16MB限制!${NC}"
    fi
    
    # 复制固件到输出目录
    mkdir -p ../../output
    cp "$FIRMWARE" ../../output/
    cp bin/targets/ar71xx/generic/openwrt-ar71xx-generic-tl-wr842n-v3-squashfs-sysupgrade.bin ../../output/ 2>/dev/null || true
    
    echo -e "${GREEN}固件已复制到 output/ 目录${NC}"
else
    echo -e "${RED}固件构建失败!${NC}"
    exit 1
fi

echo -e "${GREEN}构建完成!${NC}"
