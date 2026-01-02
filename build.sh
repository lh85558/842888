#!/bin/bash
# TP842Nv3 打印服务器 LEDE 固件一键构建脚本
# 基于 Ubuntu 22.04 LTS

set -e

echo "=== TP842Nv3 打印服务器 LEDE 固件构建脚本 ==="
echo "目标: 创建包含CUPS 2.4.2中文打印服务的16M固件"
echo ""

# 检查构建环境
check_environment() {
    echo "检查构建环境..."
    
    # 检查Ubuntu版本
    if ! grep -q "Ubuntu 22.04" /etc/os-release; then
        echo "警告: 建议使用Ubuntu 22.04 LTS"
    fi
    
    # 检查必要工具
    local required_tools=("git" "build-essential" "libncurses5-dev" "zlib1g-dev" "gawk" "flex" "git" "gettext" "libssl-dev" "xsltproc" "rsync" "wget" "unzip" "python3")
    
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            echo "安装缺失工具: $tool"
            sudo apt-get update && sudo apt-get install -y "$tool"
        fi
    done
    
    echo "环境检查完成"
}

# 下载OpenWrt源码
download_openwrt() {
    echo "下载OpenWrt 22.03.x稳定版源码..."
    
    if [ ! -d "openwrt" ]; then
        git clone https://git.openwrt.org/openwrt/openwrt.git -b openwrt-22.03
    fi
    
    cd openwrt
    ./scripts/feeds update -a
    ./scripts/feeds install -a
}

# 配置目标硬件
configure_target() {
    echo "配置TP842Nv3 (AR9531)目标硬件..."
    
    cat > .config << 'EOF'
# Target System
CONFIG_TARGET_ath79=y
CONFIG_TARGET_ath79_generic=y
CONFIG_TARGET_ath79_generic_DEVICE_tplink_tl-wr842n-v3=y

# Base system
CONFIG_PACKAGE_base-files=y
CONFIG_PACKAGE_busybox=y
CONFIG_PACKAGE_dnsmasq=y
CONFIG_PACKAGE_dropbear=y
CONFIG_PACKAGE_firewall4=y
CONFIG_PACKAGE_kmod-nft-offload=y
CONFIG_PACKAGE_kmod-nft-core=y
CONFIG_PACKAGE_kmod-nft-nat=y
CONFIG_PACKAGE_kmod-nft-nat6=y
CONFIG_PACKAGE_libustream-wolfssl=y
CONFIG_PACKAGE_opkg=y
CONFIG_PACKAGE_ppp=y
CONFIG_PACKAGE_ppp-mod-pppoe=y
CONFIG_PACKAGE_uclient-fetch=y
CONFIG_PACKAGE_urandom-seed=y
CONFIG_PACKAGE_urngd=y

# Wireless
CONFIG_PACKAGE_hostapd-common=y
CONFIG_PACKAGE_wpad-basic-wolfssl=y
CONFIG_PACKAGE_kmod-ath=y
CONFIG_PACKAGE_kmod-ath9k=y
CONFIG_PACKAGE_kmod-ath9k-common=y
CONFIG_PACKAGE_kmod-cfg80211=y
CONFIG_PACKAGE_kmod-mac80211=y

# USB Support
CONFIG_PACKAGE_kmod-usb-core=y
CONFIG_PACKAGE_kmod-usb2=y
CONFIG_PACKAGE_kmod-usb-ohci=y
CONFIG_PACKAGE_kmod-usb-ehci=y
CONFIG_PACKAGE_kmod-usb-printer=y
CONFIG_PACKAGE_kmod-usb-storage=y
CONFIG_PACKAGE_kmod-usb-storage-uas=y
CONFIG_PACKAGE_kmod-fs-vfat=y
CONFIG_PACKAGE_kmod-fs-ext4=y
CONFIG_PACKAGE_block-mount=y

# CUPS Printing
CONFIG_PACKAGE_cups=y
CONFIG_PACKAGE_cups-bjnp=y
CONFIG_PACKAGE_cups-client=y
CONFIG_PACKAGE_cups-drivers=y
CONFIG_PACKAGE_cups-filters=y
CONFIG_PACKAGE_cups-ppdc=y
CONFIG_PACKAGE_cups-server=y
CONFIG_PACKAGE_libcups=y
CONFIG_PACKAGE_libcupscgi=y
CONFIG_PACKAGE_libcupsimage=y
CONFIG_PACKAGE_libcupsmime=y
CONFIG_PACKAGE_libcupsppdc=y

# Language Support
CONFIG_PACKAGE_luci-i18n-base-zh-cn=y
CONFIG_PACKAGE_luci-i18n-firewall-zh-cn=y
CONFIG_PACKAGE_luci-i18n-opkg-zh-cn=y
CONFIG_PACKAGE_kmod-nls-base=y
CONFIG_PACKAGE_kmod-nls-cp437=y
CONFIG_PACKAGE_kmod-nls-iso8859-1=y
CONFIG_PACKAGE_kmod-nls-utf8=y

# Web Interface
CONFIG_PACKAGE_luci=y
CONFIG_PACKAGE_luci-base=y
CONFIG_PACKAGE_luci-mod-admin-full=y
CONFIG_PACKAGE_luci-theme-bootstrap=y
CONFIG_PACKAGE_luci-app-firewall=y
CONFIG_PACKAGE_luci-app-opkg=y

# Utilities
CONFIG_PACKAGE_coreutils=y
CONFIG_PACKAGE_coreutils-base64=y
CONFIG_PACKAGE_curl=y
CONFIG_PACKAGE_htop=y
CONFIG_PACKAGE_iwinfo=y
CONFIG_PACKAGE_kmod-crypto-hash=y
CONFIG_PACKAGE_kmod-crypto-null=y
CONFIG_PACKAGE_libopenssl=y
CONFIG_PACKAGE_openssl-util=y
CONFIG_PACKAGE_rpcd=y
CONFIG_PACKAGE_rpcd-mod-file=y
CONFIG_PACKAGE_rpcd-mod-iwinfo=y
CONFIG_PACKAGE_rpcd-mod-luci=y
CONFIG_PACKAGE_rpcd-mod-rrdns=y
CONFIG_PACKAGE_uhttpd=y
CONFIG_PACKAGE_uhttpd-mod-ubus=y

# Size optimization - remove unnecessary packages
# CONFIG_PACKAGE_ipv6helper is not set
# CONFIG_PACKAGE_kmod-ipt-nat6 is not set
# CONFIG_PACKAGE_kmod-nf-nat6 is not set
# CONFIG_PACKAGE_kmod-ppp is not set
# CONFIG_PACKAGE_kmod-pppoe is not set
# CONFIG_PACKAGE_kmod-pppox is not set
# CONFIG_PACKAGE_ppp-mod-pppoe is not set
EOF

    make defconfig
}

# 复制自定义文件
copy_custom_files() {
    echo "复制自定义配置文件..."
    
    # 创建自定义文件目录
    mkdir -p files/etc/config
    mkdir -p files/etc/cups
    mkdir -p files/etc/hotplug.d/usb
    mkdir -p files/etc/init.d
    mkdir -p files/www/luci-static/resources/icons
    
    # 复制网络配置
    cp ../configs/network files/etc/config/
    cp ../configs/wireless files/etc/config/
    cp ../configs/system files/etc/config/
    cp ../configs/cupsd.conf files/etc/cups/
    cp ../configs/cups-files.conf files/etc/cups/
    
    # 复制启动脚本
    cp ../scripts/cupsd.init files/etc/init.d/cupsd
    chmod +x files/etc/init.d/cupsd
    
    cp ../scripts/usb-printer.hotplug files/etc/hotplug.d/usb/20-printer
    chmod +x files/etc/hotplug.d/usb/20-printer
    
    # 复制定时重启脚本
    cp ../scripts/reboot-cron files/etc/crontabs/root
    
    # 复制HP打印机驱动PPD文件
    cp ../drivers/hp-lj1020.ppd files/etc/cups/ppd/
}

# 构建固件
build_firmware() {
    echo "开始构建固件..."
    
    # 清理之前的构建
    make clean
    
    # 开始编译
    make -j$(nproc) V=s
    
    echo "构建完成！固件位置: bin/targets/ath79/generic/"
    ls -la bin/targets/ath79/generic/*842n-v3*
}

# 主函数
main() {
    check_environment
    download_openwrt
    configure_target
    copy_custom_files
    build_firmware
}

# 如果直接运行脚本
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi
