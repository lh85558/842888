# THDN TP842Nv3 LEDE打印服务器固件项目

.PHONY: all clean build download menuconfig

# 默认目标
all: build

# 构建固件
build:
	@echo "=== 开始构建TP842Nv3打印服务器固件 ==="
	@chmod +x build.sh
	@./build.sh

# 下载源码
download:
	@echo "=== 下载OpenWrt源码 ==="
	@mkdir -p openwrt-build
	@cd openwrt-build && \
	if [ ! -d "openwrt" ]; then \
		git clone https://gitcode.com/lh85558/openwrt.git openwrt; \
	fi && \
	cd openwrt && \
	./scripts/feeds update -a && \
	./scripts/feeds install -a

# 配置菜单
menuconfig: download
	@echo "=== 打开配置菜单 ==="
	@cd openwrt-build/openwrt && \
	cp ../../diffconfig .config 2>/dev/null || true && \
	make defconfig && \
	make menuconfig

# 清理构建
clean:
	@echo "=== 清理构建文件 ==="
	@rm -rf openwrt-build
	@rm -rf output
	@echo "清理完成"

# 安装依赖
deps:
	@echo "=== 安装构建依赖 ==="
	@sudo apt update
	@sudo apt install -y \
		build-essential ccache ecj fastjar file g++ gawk \
		gettext git java-propose-classpath libelf-dev libncurses5-dev \
		libncursesw5-dev libssl-dev python python2.7-dev python3 unzip wget \
		python3-distutils python3-setuptools python3-dev rsync subversion \
		swig time xsltproc zlib1g-dev

# 帮助
help:
	@echo "THDN TP842Nv3 LEDE打印服务器固件构建系统"
	@echo ""
	@echo "可用目标:"
	@echo "  make build      - 构建完整固件"
	@echo "  make download   - 下载并准备源码"
	@echo "  make menuconfig - 打开配置菜单"
	@echo "  make clean      - 清理构建文件"
	@echo "  make deps       - 安装构建依赖"
	@echo "  make help       - 显示此帮助"
	@echo ""
	@echo "快速开始:"
	@echo "  1. make deps     - 安装依赖"
	@echo "  2. make build    - 构建固件"
	@echo ""
	@echo "输出文件将在 output/ 目录中"

# 显示项目信息
info:
	@echo "=== THDN TP842Nv3 LEDE打印服务器项目信息 ==="
	@echo "目标硬件: TP-Link TL-WR842Nv3 (AR9531)"
	@echo "固件大小: ≤16MB"
	@echo "主要功能:"
	@echo "  - CUPS 2.4.2 中文打印服务"
	@echo "  - HP LaserJet 1020/1020plus/1007/1008/1108驱动"
	@echo "  - USB和网络打印机支持"
	@echo "  - 中文LuCI界面"
	@echo "  - 定时重启功能"
	@echo ""
	@echo "网络配置:"
	@echo "  - LAN IP: 192.168.10.1"
	@echo "  - WiFi SSID: THDN-dayin"
	@echo "  - WiFi密码: thdn12345678"
	@echo "  - 管理账号: admin/thdn12345678"
