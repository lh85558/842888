# TP842Nv3 LEDE 打印服务器固件

为TP-Link TL-WR842Nv3 (AR9531)路由器定制的LEDE/OpenWrt固件，集成CUPS打印服务。

## 功能特性

- **打印服务**: CUPS 2.4.2 中文打印服务
- **打印机支持**: HP LaserJet 1020/1020plus/1007/1008/1108
- **连接方式**: USB打印机即插即用，网络打印机支持
- **系统管理**: 中文LuCI界面，定时重启
- **网络配置**: 
  - LAN IP: 192.168.10.1
  - WiFi SSID: THDN-dayin
  - WiFi密码: thdn12345678
- **登录信息**: admin / thdn12345678

## 快速开始

### 本地构建

```bash
# 安装依赖
sudo apt update
sudo apt install -y build-essential ccache ecj fastjar file g++ gawk \
gettext git java-propose-classpath libelf-dev libncurses5-dev \
libncursesw5-dev libssl-dev python python2.7-dev python3 unzip wget \
python3-distutils python3-setuptools python3-dev rsync subversion \
swig time xsltproc zlib1g-dev

# 克隆项目
git clone https://github.com/your-username/tp842nv3-printserver.git
cd tp842nv3-printserver

# 开始构建
./build.sh
```

### GitHub Actions云编译

1. Fork此仓库
2. 在GitHub仓库页面点击"Actions"标签
3. 选择"Build Firmware"工作流
4. 点击"Run workflow"

## 固件说明

- 目标固件大小: ≤16MB
- 包含CUPS打印服务及HP驱动
- 支持USB和网络打印机
- 中文管理界面
- 自动定时重启功能

## 项目结构

```
.
├── .github/
│   └── workflows/
│       └── build.yml          # GitHub Actions构建脚本
├── files/
│   ├── etc/
│   │   ├── config/            # 预配置文件
│   │   ├── cups/               # CUPS配置
│   │   ├── hotplug.d/          # USB热插拔脚本
│   │   └── uci-defaults/       # 系统初始化脚本
│   ├── package/
│   │   ├── cups/               # CUPS软件包
│   │   └── foo2zjs/            # HP打印机驱动
│   └── scripts/
│       └── setup.sh            # 环境设置脚本
├── diffconfig                   # 精简配置
├── feeds.conf                   # 软件源配置
└── build.sh                     # 一键构建脚本
```

## 支持的打印机型号

- HP LaserJet 1020
- HP LaserJet 1020plus  
- HP LaserJet 1007
- HP LaserJet 1008
- HP LaserJet 1108

## 使用说明

1. 刷入固件后，访问 http://192.168.10.1
2. 使用 admin/thdn12345678 登录
3. 连接USB打印机或配置网络打印机
4. 通过CUPS管理界面添加打印机

## 许可证

MIT License

## 技术支持

如有问题请在GitHub提交Issue。
