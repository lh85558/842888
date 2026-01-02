#!/bin/bash
# TP842Nv3 打印服务器快速构建脚本
# 简化版本，适合快速编译

set -e

echo "=== TP842Nv3 打印服务器快速构建 ==="
echo ""

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查并安装依赖
check_dependencies() {
    log_info "检查构建依赖..."
    
    local deps=("build-essential" "ccache" "ecj" "fastjar" "file" "g++" "gawk" \
                "gettext" "git" "java-propose-classpath" "libelf-dev" "libncurses5-dev" \
                "libncursesw5-dev" "libssl-dev" "python" "python2.7-dev" "python3" "unzip" \
                "wget" "python3-distutils" "python3-setuptools" "python3-dev" "rsync" "swig" \
                "time" "xsltproc" "zlib1g-dev" "subversion" "git-core" "openssl" "libssl-dev" \
                "libffi-dev" "libxml2-dev" "libxslt1-dev" "python3-pip" "python3-venv")
    
    for dep in "${deps[@]}"; do
        if ! dpkg -l | grep -q "^ii  $dep "; then
            log_info "安装缺失依赖: $dep"
            sudo apt-get update && sudo apt-get install -y "$dep"
        fi
    done
}

# 下载OpenWrt源码
download_source() {
    log_info "下载OpenWrt源码..."
    
    if [ ! -d "openwrt" ]; then
        git clone https://git.openwrt.org/openwrt/openwrt.git -b openwrt-22.03 openwrt
    else
        log_info "源码目录已存在，更新源码..."
        cd openwrt
        git pull
        cd ..
    fi
}

# 更新和安装软件包
update_feeds() {
    log_info "更新软件包源..."
    cd openwrt
    ./scripts/feeds update -a
    ./scripts/feeds install -a
    cd ..
}

# 应用配置
apply_config() {
    log_info "应用配置文件..."
    cd openwrt
    
    # 复制配置文件
    cp ../configs/openwrt-config .config
    cp ../configs/size-optimization.config .config.append
    
    # 合并配置
    cat .config.append >> .config
    
    # 应用配置
    make defconfig
    
    cd ..
}

# 构建固件
build_firmware() {
    log_info "开始构建固件..."
    cd openwrt
    
    # 清理之前的构建
    make clean
    
    # 开始编译
    log_info "编译中...这可能需要几个小时"
    make -j$(nproc) V=s
    
    # 检查构建结果
    if [ -f "bin/targets/ath79/generic/openwrt-ath79-generic-tplink_tl-wr842n-v3-squashfs-factory.bin" ]; then
        log_info "构建成功！"
        log_info "固件文件:"
        ls -lh bin/targets/ath79/generic/*842n-v3*
        
        # 复制固件到输出目录
        mkdir -p ../output
        cp bin/targets/ath79/generic/*842n-v3* ../output/
        log_info "固件已复制到 output/ 目录"
    else
        log_error "构建失败！请检查错误信息"
        exit 1
    fi
    
    cd ..
}

# 显示使用说明
show_usage() {
    log_info "使用方法:"
    echo "  ./quick-build.sh [命令]"
    echo ""
    echo "命令:"
    echo "  deps      - 安装依赖"
    echo "  download  - 下载源码"
    echo "  config    - 应用配置"
    echo "  build     - 构建固件"
    echo "  all       - 执行完整构建流程"
    echo ""
    echo "示例:"
    echo "  ./quick-build.sh all    # 完整构建"
    echo "  ./quick-build.sh build  # 仅构建"
}

# 主函数
main() {
    case "${1:-all}" in
        deps)
            check_dependencies
            ;;
        download)
            download_source
            update_feeds
            ;;
        config)
            apply_config
            ;;
        build)
            build_firmware
            ;;
        all)
            check_dependencies
            download_source
            update_feeds
            apply_config
            build_firmware
            ;;
        *)
            show_usage
            ;;
    esac
}

# 运行主函数
main "$@"
