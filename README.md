# TP842Nv3 打印服务器 LEDE 固件

这是一个为TP-Link TL-WR842N v3路由器定制的LEDE/OpenWrt固件，集成了CUPS 2.4.2中文打印服务，支持HP LaserJet 1020/1020 Plus打印机。

## 功能特性

- **硬件支持**: TP-Link TL-WR842N v3 (AR9531芯片，16M Flash)
- **打印服务**: CUPS 2.4.2 中文Web界面
- **驱动支持**: 预装HP LaserJet 1020/1020 Plus驱动
- **USB支持**: USB打印机即插即用
- **网络打印**: 支持网络打印机共享
- **系统管理**: 定时重启、中文LuCI界面
- **网络配置**: 
  - LAN IP: 192.168.10.1
  - Wi-Fi SSID: THDN-dayin
  - Wi-Fi密码: thdn12345678
- **登录凭据**: admin / thdn12345678
- **主机名**: THDN-PrintServer

## 构建环境

- **操作系统**: Ubuntu 22.04 LTS (推荐)
- **内存**: 至少4GB RAM
- **存储**: 至少20GB可用磁盘空间
- **网络**: 稳定的互联网连接

## 快速开始

### 1. 安装依赖

```bash
sudo apt-get update
sudo apt-get install -y build-essential ccache ecj fastjar file g++ gawk \
  gettext git java-propose-classpath libelf-dev libncurses5-dev \
  libncursesw5-dev libssl-dev python python2.7-dev python3 unzip \
  wget python3-distutils python3-setuptools python3-dev rsync swig \
  time xsltproc zlib1g-dev subversion git-core openssl libssl-dev \
  libffi-dev libxml2-dev libxslt1-dev python3-pip python3-venv
```

### 2. 一键构建

```bash
# 赋予执行权限
chmod +x quick-build.sh

# 完整构建流程
./quick-build.sh all

# 或者分步骤构建
./quick-build.sh deps      # 安装依赖
./quick-build.sh download  # 下载源码
./quick-build.sh config    # 应用配置
./quick-build.sh build     # 构建固件
```

### 3. 构建输出

构建完成后，固件文件将保存在 `output/` 目录中：
- `openwrt-ath79-generic-tplink_tl-wr842n-v3-squashfs-factory.bin` - 原厂固件
- `openwrt-ath79-generic-tplink_tl-wr842n-v3-squashfs-sysupgrade.bin` - 升级固件

## 固件安装

### 通过Web界面安装

1. 连接到路由器的原厂Web界面（通常是192.168.0.1或192.168.1.1）
2. 登录管理员账户
3. 导航到"系统工具" → "固件升级"
4. 选择`factory.bin`文件
5. 点击升级并等待完成

### 通过TFTP安装

1. 设置TFTP服务器
2. 将固件重命名为`tp_recovery.bin`
3. 按住路由器复位键开机
4. 通过TFTP上传固件

## 使用指南

### 1. 初始设置

固件安装完成后：
- 连接到Wi-Fi网络 `THDN-dayin` (密码: thdn12345678)
- 或通过网线连接到LAN口
- 访问管理界面: http://192.168.10.1
- 登录账户: admin / thdn12345678

### 2. 打印机设置

1. **USB打印机**:
   - 将HP LaserJet 1020打印机连接到USB口
   - 系统会自动识别并配置打印机
   - 访问 http://192.168.10.1:631 查看CUPS管理界面

2. **网络打印**:
   - Windows: 添加网络打印机 → 输入`\\192.168.10.1/HP_LaserJet_1020`
   - macOS: 系统偏好设置 → 打印机与扫描仪 → 添加IP打印机
   - Linux: CUPS管理界面 → 添加网络打印机

### 3. 管理功能

- **定时重启**: 每周日凌晨3点自动重启
- **日志清理**: 每天凌晨4点清理过期日志
- **临时文件清理**: 每天凌晨5点清理CUPS临时文件

## 文件结构

```
.
├── build.sh                    # 完整构建脚本
├── quick-build.sh             # 快速构建脚本
├── configs/                   # 配置文件目录
│   ├── network               # 网络配置
│   ├── wireless              # 无线配置
│   ├── system                # 系统配置
│   ├── cupsd.conf            # CUPS主配置
│   ├── cups-files.conf       # CUPS文件配置
│   ├── luci.config           # LuCI界面配置
│   ├── openwrt-config        # OpenWrt主配置
│   └── size-optimization.config # 大小优化配置
├── scripts/                   # 脚本目录
│   ├── cupsd.init            # CUPS启动脚本
│   ├── usb-printer.hotplug   # USB打印机热插拔脚本
│   └── reboot-cron           # 定时重启任务
├── drivers/                   # 驱动目录
│   └── hp-lj1020.ppd         # HP LaserJet 1020驱动
└── output/                    # 构建输出目录
```

## 故障排除

### 构建问题

1. **依赖错误**: 确保所有依赖已正确安装
2. **磁盘空间**: 确保有足够的磁盘空间
3. **网络连接**: 构建过程需要稳定的网络连接

### 打印问题

1. **打印机未识别**: 检查USB连接，查看系统日志
2. **打印质量问题**: 在CUPS界面调整打印质量设置
3. **网络打印失败**: 检查防火墙设置，确保端口631开放

### 网络问题

1. **无法连接**: 检查IP地址设置，尝试重置网络
2. **Wi-Fi问题**: 检查无线配置，尝试重新配置

## 技术支持

- **OpenWrt官方文档**: https://openwrt.org/docs/start
- **CUPS文档**: https://www.cups.org/doc/
- **HP驱动支持**: https://support.hp.com

## 许可证

本项目基于OpenWrt和CUPS的开源许可证发布。

## 更新日志

### v1.0.0 (2026-01-02)
- 初始版本发布
- 集成CUPS 2.4.2中文打印服务
- 支持HP LaserJet 1020/1020 Plus
- 优化固件大小至16M以内
- 添加定时重启和日志清理功能
