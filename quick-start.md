# TP842Nv3 LEDE打印服务器 - 快速开始指南

## 🚀 快速构建

### 1. 一键构建（推荐）
```bash
# 克隆项目
git clone https://github.com/your-username/tp842nv3-printserver.git
cd tp842nv3-printserver

# 一键构建
make build
```

### 2. 分步构建
```bash
# 安装依赖
make deps

# 下载源码
make download

# 配置（可选）
make menuconfig

# 构建固件
make build
```

## 📋 系统要求

- **操作系统**: Ubuntu 22.04 LTS (推荐)
- **CPU**: 至少2核心
- **内存**: 至少4GB
- **存储**: 至少20GB可用空间
- **网络**: 稳定的互联网连接

## 🔧 项目结构

```
tp842nv3-printserver/
├── build.sh              # 主构建脚本
├── Makefile              # 构建系统
├── diffconfig            # 精简配置
├── feeds.conf            # 软件源配置
├── README.md             # 项目文档
├── quick-start.md        # 快速开始指南
├── .github/
│   └── workflows/
│       └── build.yml     # GitHub Actions工作流
├── files/                # 自定义文件
│   ├── etc/
│   │   ├── config/       # 配置文件
│   │   ├── cups/         # CUPS配置
│   │   ├── hotplug.d/    # 热插拔脚本
│   │   ├── init.d/       # 启动脚本
│   │   ├── uci-defaults/ # 系统初始化
│   │   └── crontabs/     # 定时任务
│   ├── package/          # 自定义软件包
│   │   ├── cups/         # CUPS软件包
│   │   └── foo2zjs/      # HP驱动软件包
│   ├── usr/
│   │   └── lib/lua/luci/ # LuCI界面文件
│   └── www/              # Web界面文件
└── scripts/              # 辅助脚本
    └── setup.sh          # 环境设置脚本
```

## 🖨️ 支持的打印机

| 型号 | USB ID | 驱动 | 状态 |
|------|--------|------|------|
| HP LaserJet 1020 | 03f0:2b17 | foo2zjs | ✅ |
| HP LaserJet 1020plus | 03f0:3d17 | foo2zjs | ✅ |
| HP LaserJet 1007 | 03f0:4117 | foo2xqx | ✅ |
| HP LaserJet 1008 | 03f0:4217 | foo2xqx | ✅ |
| HP LaserJet 1108 | 03f0:4317 | foo2hp | ✅ |

## 🔌 默认配置

### 网络设置
- **LAN IP**: 192.168.10.1
- **子网掩码**: 255.255.255.0
- **DHCP范围**: 192.168.10.100-192.168.10.250

### WiFi设置
- **SSID**: THDN-dayin
- **密码**: thdn12345678
- **加密**: WPA2-PSK
- **信道**: 6

### 管理设置
- **Web管理**: http://192.168.10.1
- **用户名**: admin
- **密码**: thdn12345678
- **主机名**: THDN-PrintServer

### CUPS设置
- **端口**: 631
- **Web界面**: 启用
- **远程管理**: 禁用（安全考虑）

## 🌐 访问方式

### 1. Web管理界面
- 地址: http://192.168.10.1
- 登录: admin / thdn12345678

### 2. CUPS管理界面
- 地址: http://192.168.10.1:631
- 功能: 添加/管理打印机

### 3. SSH访问
- 地址: 192.168.10.1
- 端口: 22
- 用户名: root（无密码，首次登录设置）

## 📄 使用说明

### USB打印机
1. 将打印机连接到路由器的USB端口
2. 等待系统自动识别（约30秒）
3. 访问CUPS界面添加打印机
4. 或使用Web管理界面自动配置

### 网络打印机
1. 确保打印机和路由器在同一网络
2. 访问CUPS界面添加网络打印机
3. 输入打印机IP地址或网络名称

### 打印测试
```bash
# 命令行测试
lp /etc/passwd

# 查看打印机状态
lpstat -p

# 查看打印队列
lpq
```

## 🔧 故障排除

### 常见问题

#### 1. 固件大小超过16MB
```bash
# 检查固件大小
ls -lh output/*.bin

# 重新配置，禁用不需要的功能
make menuconfig
```

#### 2. USB打印机无法识别
```bash
# 检查USB设备
lsusb

# 检查打印机状态
cat /tmp/printer_status

# 重启CUPS服务
/etc/init.d/cups restart
```

#### 3. CUPS服务无法启动
```bash
# 检查日志
cat /var/log/cups/error_log

# 检查配置
cupsd -t

# 重新安装CUPS
opkg remove cups
opkg install cups
```

#### 4. 中文界面显示异常
```bash
# 检查语言包
opkg list-installed | grep luci-i18n

# 重新安装中文包
opkg install luci-i18n-base-zh-cn
```

## 📊 性能优化

### 内存优化
- 禁用不需要的服务
- 精简日志级别
- 使用轻量级配置

### 存储优化
- 固件大小控制在16MB以内
- 使用SquashFS文件系统
- 优化软件包选择

### 网络优化
- 启用QoS（可选）
- 优化WiFi参数
- 配置合适的信道

## 🔄 更新和维护

### 系统更新
```bash
# 更新软件包列表
opkg update

# 升级已安装包
opkg upgrade
```

### 备份配置
```bash
# 备份系统配置
sysupgrade -b /tmp/backup.tar.gz

# 备份CUPS配置
tar -czf /tmp/cups-backup.tar.gz /etc/cups/
```

### 恢复配置
```bash
# 恢复系统配置
sysupgrade -r /tmp/backup.tar.gz

# 恢复CUPS配置
tar -xzf /tmp/cups-backup.tar.gz -C /
```

## 📞 技术支持

### 获取帮助
1. 查看系统日志: `logread`
2. 检查CUPS日志: `cat /var/log/cups/error_log`
3. 查看打印机状态: `lpstat -p`
4. 检查网络连接: `ping 192.168.10.1`

### 报告问题
- GitHub Issues: [项目地址]/issues
- 提供信息: 系统日志、配置文件、错误信息

## 🎯 下一步

1. **测试固件**: 在TP842Nv3设备上测试
2. **验证功能**: 确保所有打印功能正常
3. **性能测试**: 检查系统稳定性和性能
4. **用户反馈**: 收集使用反馈并改进

---

**祝使用愉快！** 🎉
